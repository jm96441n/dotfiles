---
name: gremlin
description: Write Gremlin graph traversal queries for Neptune using the gremlin-go driver patterns in this codebase
license: MIT
compatibility: opencode
metadata:
  audience: developers
  domain: graph-database
---

## Overview

This skill helps write Gremlin graph traversal queries using the `github.com/apache/tinkerpop/gremlin-go/v3/driver` library against AWS Neptune. The codebase has a two-layer architecture:

1. **gremlin.Store** (`internal/storage/gremlin/store.go`) - Low-level connection management
2. **graph.Store** (`internal/storage/graph/store.go`) - Higher-level node/edge operations

## Key Patterns

### Getting a Traversal Source

Always obtain traversals through the Store, specifying read-only or read-write:

```go
// For read operations
g, err := s.gremlinStore.ReadOnlyTraversal(customerID)

// For write operations
g, err := s.gremlinStore.ReadWriteTraversal(customerID)
```

The `customerID` is used as a partition key for multi-tenancy via `PartitionStrategy`.

### Reserved Properties

These internal properties are prefixed with `_` and managed automatically:

| Property | Constant | Purpose |
|----------|----------|---------|
| `_modified_time` | `gremlin.ModifiedTimeProperty` | Last modification timestamp |
| `_owner` | `gremlin.OwnerProperty` | Resource owner identifier |
| `CustomerID` | `gremlin.PartitionKey` | Multi-tenant partition key |

### Common Traversal Patterns

#### Get a vertex by ID with all properties:
```go
result, err := g.V(nodeID).ValueMap().With(gremlingo.WithOptions.Tokens).ToList()
```

#### Filter vertices by label:
```go
g.V().HasLabel("INSTANCE", "SECURITY_GROUP")
```

#### Filter by property value:
```go
g.V().Has("name", gremlingo.P.Eq("my-resource"))
g.V().Has(gremlin.ModifiedTimeProperty, gremlingo.P.Gte(modTime))
```

#### Traverse edges (outgoing):
```go
g.V(sourceID).OutE("ATTACHES_TO").InV()
```

#### Traverse edges (incoming):
```go
g.V(destID).InE("BELONGS_TO").OutV()
```

#### Get edge with source and destination:
```go
g.V(source).OutE(label).Where(gremlingo.T__.InV().HasId(dest))
```

#### Project specific fields from edges:
```go
g.E().
    Project("id", "label", "mod", "out", "in", "customer", "owner").
    By(gremlingo.T.Id).
    By(gremlingo.T.Label).
    By(modifiedTimeProperty).
    By(gremlingo.T__.OutV().Id()).
    By(gremlingo.T__.InV().Id()).
    By(partitionKey).
    By(ownerProperty).
    ToList()
```

### Upsert Pattern (Merge)

Use `MergeV` for vertices and `MergeE` for edges:

```go
// Upsert vertex
g.MergeV(map[any]any{gremlingo.T.Id: nodeID}).
    Option(gremlingo.Merge.OnCreate, map[any]any{
        gremlingo.T.Label: label,
        gremlingo.T.Id:    id,
        "prop1":           gremlingo.CardinalityValue.Single(value),
    }).
    Option(gremlingo.Merge.OnMatch, updateTraversal).
    ToList()

// Upsert edge
g.MergeE(map[any]any{
    gremlingo.T.Label:        edgeLabel,
    gremlingo.Direction.To:   destNodeID,
    gremlingo.Direction.From: sourceNodeID,
}).
    Option(gremlingo.Merge.OnCreate, createMap).
    Option(gremlingo.Merge.OnMatch, updateTraversal).
    Next()
```

### Conditional Updates

Only update if the incoming data is newer:

```go
gremlingo.T__.Choose(
    gremlingo.T__.Or(
        gremlingo.T__.Not(gremlingo.T__.Has(modifiedTimeProperty)),
        gremlingo.T__.Values(modifiedTimeProperty).Is(gremlingo.P.Lt(newModTime)),
    ),
    // If true: update
    updateTraversal,
    // Else: no-op
    gremlingo.T__.Identity(),
).Constant(map[any]any{})
```

### Anonymous Traversals

Use `gremlingo.T__` for anonymous traversals (filter conditions, nested steps):

```go
// Check property exists
gremlingo.T__.Has("propertyName")

// Check property does not exist
gremlingo.T__.HasNot("propertyName")

// Combine conditions
gremlingo.T__.And(condition1, condition2)
gremlingo.T__.Or(condition1, condition2)
```

### Delete Operations

```go
// Delete a vertex (also removes connected edges)
g.V(nodeID).Drop().Iterate()

// Delete an edge
g.V(sourceID).OutE(label).Where(gremlingo.T__.InV().HasId(destID)).Drop().Iterate()

// Clear all data for a customer
g.E().Drop().Iterate()
g.V().Drop().Iterate()
```

### Path Queries (Query API)

The query API uses path traversals for returning connected subgraphs:

```go
g.V().
    HasLabel("EC2_INSTANCE").
    OutE("ATTACHES_TO").InV().
    Order().By(gremlingo.T.Id).
    Range(low, high).
    Path().By(gremlingo.T__.ElementMap()).
    ToList()
```

### Transaction Management

For atomic multi-step operations, use transactions:

```go
// Open transaction
tx, gts, err := s.gremlinStore.ReadWriteTxTraversal(customerID)

// Perform operations using gts...

// Commit or rollback
err = tx.Commit()
// or
err = tx.Rollback()
```

The `graph.Store` provides higher-level transaction management:
```go
s.OpenTx(customerID)
// ... operations ...
s.CommitTx(customerID)
```

### Predicates

| Predicate | Usage |
|-----------|-------|
| `gremlingo.P.Eq(val)` | Equals |
| `gremlingo.P.Neq(val)` | Not equals |
| `gremlingo.P.Lt(val)` | Less than |
| `gremlingo.P.Lte(val)` | Less than or equal |
| `gremlingo.P.Gt(val)` | Greater than |
| `gremlingo.P.Gte(val)` | Greater than or equal |

### Result Handling

Results come back as `[]*gremlingo.Result`. Extract data like:

```go
results, err := g.V().ToList()
for _, result := range results {
    data, ok := result.Data.(map[any]any)
    // Process data...
}

// For single result
result, err := g.V(id).Next()
```

## Testing Gremlin Queries

Use `testutil.SetupDataStores` to get a real Gremlin container:

```go
func TestMyGremlinQuery(t *testing.T) {
    t.Parallel()
    ctx := context.Background()
    ds := testutil.SetupDataStores(ctx, t)
    
    // ds.GremlinStore is a *gremlin.Store
    // ds.GraphStore is a *graph.Store
}
```

## Common Gotchas

1. **Always use `ToList()` or `Iterate()`** - These terminate the traversal and return the connection to the pool
2. **Property values are wrapped in arrays** - When using `ValueMap()`, values come back as `[]any`
3. **Type assertions are required** - Results are `any` type, always check casts
4. **Partition strategy is automatic** - Don't manually filter by CustomerID, it's handled by the strategy
5. **Time comparisons** - Use `time.Time` directly, it's serialized correctly

## Files Reference

- `internal/storage/gremlin/store.go` - Connection and traversal management
- `internal/storage/graph/store.go` - Node/edge CRUD operations
- `internal/queryapi/processor.go` - Complex query building for the Query API
