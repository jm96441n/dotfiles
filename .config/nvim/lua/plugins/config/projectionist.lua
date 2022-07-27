local vim = vim

vim.api.nvim_exec([[
  augroup projection_extension
    let args = {}
    let args['*.go'] =          { 'alternate': '{}_test.go' }
    let args['*_test.go'] =     { 'alternate': '{}.go' }
    let args['*.py'] =          { 'alternate': 'test_{}.py' }
    let args['test_*.py'] =     { 'alternate': '{}.py' }
    let args['*.up.sql'] =      { 'alternate': '{}.down.sql' }
    let args['*.down.sql'] =    { 'alternate': '{}.up.sql' }
    autocmd User ProjectionistDetect call projectionist#append(getcwd(), args)
  augroup END
]], false)
