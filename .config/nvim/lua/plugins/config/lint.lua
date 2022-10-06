local lint = require("lint")

lint.linters_by_ft = {
	python = { "flake8", "mypy" },
	go = { "golangcilint" },
	ruby = { "rubocop" },
	markdown = { "vale" },
}
