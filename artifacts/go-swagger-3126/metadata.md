# go-swagger #3126 submission

- Repository: go-swagger/go-swagger (Apache-2.0)
- Base commit: 435dc19b1c0a94ed6aa68e36e9918eb45b9f7049 (2026-08-09, "fix(generator): don't crash generating enum const block on null value (#3421)")
- Issue: https://github.com/go-swagger/go-swagger/issues/3126
- Title: Deduplicate generated response types shared across operations
- Category: Feature Request
- Language: Go
- Difficulty: hard
- Files: description.md, test.patch, solution.patch, Dockerfile, test.sh

Run: `./test.sh --output_path results.xml base|new`
- base: every test of ./generator/... except `TestSharedNamedResponses*` and the network-bound
  `TestGenerateAndBuild`, `TestGenerateAndTest`, `TestGenClient`.
- new: `^TestSharedNamedResponses` in ./generator/ (10 tests, 15 JUnit test cases).
