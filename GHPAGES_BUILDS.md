There're 2 GitHub actions workflows at data_table_2/.github/workflows/ which help with deployments to GitHub pages:
- dev_build.yml - started automatically upon each build, runs tests, pushes master build to https://maxim-saplin.github.io/data_table_2/dev/
- example.yml - started manually, used to push production/stable version of the demo and should be synced with package releases to pub.dev: https://maxim-saplin.github.io/data_table_2/
