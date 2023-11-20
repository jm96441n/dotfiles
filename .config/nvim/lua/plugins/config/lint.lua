local lint = require("lint")

lint.linters_by_ft = {
	python = { "flake8", "mypy" },
	go = { "golangcilint", "staticcheck" },
	ruby = { "rubocop" },
	markdown = { "vale" },
}
