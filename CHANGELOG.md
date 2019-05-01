# Change Log

## [v1.3.4](https://github.com/mitre/inspec_tools/tree/v1.3.4) (2019-05-01)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.1.6...v1.3.4)

**Closed issues:**

- Needed app is missing [\#49](https://github.com/mitre/inspec_tools/issues/49)
- 2018   b79e5c3 [\#48](https://github.com/mitre/inspec_tools/issues/48)

**Merged pull requests:**

- Metadata docs and tools [\#55](https://github.com/mitre/inspec_tools/pull/55) ([samcornwell](https://github.com/samcornwell))
- Fix bugs introduced by \#51 \(STIGViewer PR\) [\#52](https://github.com/mitre/inspec_tools/pull/52) ([samcornwell](https://github.com/samcornwell))
- Enhancements to meet working with STIGViewer as well as tracking some custom metadata when converting from xccdf2inspec and inspec2ckl [\#51](https://github.com/mitre/inspec_tools/pull/51) ([kevin-j-smith](https://github.com/kevin-j-smith))
- Add modules summary, compliance [\#45](https://github.com/mitre/inspec_tools/pull/45) ([rx294](https://github.com/rx294))

## [v1.1.6](https://github.com/mitre/inspec_tools/tree/v1.1.6) (2018-12-13)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.1.5...v1.1.6)

## [v1.1.5](https://github.com/mitre/inspec_tools/tree/v1.1.5) (2018-12-11)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.1.2...v1.1.5)

**Implemented enhancements:**

- Add help for the gem usage and or ruby usage [\#7](https://github.com/mitre/inspec_tools/issues/7)
- add sub-help command output to match README and document each function [\#6](https://github.com/mitre/inspec_tools/issues/6)

**Fixed bugs:**

- Add help for the gem usage and or ruby usage [\#7](https://github.com/mitre/inspec_tools/issues/7)
- add sub-help command output to match README and document each function [\#6](https://github.com/mitre/inspec_tools/issues/6)

**Closed issues:**

- add rubocop integration or PRs [\#34](https://github.com/mitre/inspec_tools/issues/34)
- Do we want to expose the --cci flag in the example as it is now not needed by default given it is in the /data directory [\#29](https://github.com/mitre/inspec_tools/issues/29)
- fix the subcommands help so it works as expected [\#28](https://github.com/mitre/inspec_tools/issues/28)
- THOR CLI: xccdf2inspec for example was giving me a hard time about the order of -x or --xccdf or --cci or -c and the order they were in - the docs on it seems to give two sets of directions [\#27](https://github.com/mitre/inspec_tools/issues/27)
- do we have to do anything special for including CIS Benchmarks? [\#21](https://github.com/mitre/inspec_tools/issues/21)
- clean up debug statements [\#20](https://github.com/mitre/inspec_tools/issues/20)
- Give attribution for files in /data [\#19](https://github.com/mitre/inspec_tools/issues/19)
- add copyright statements if necessary [\#15](https://github.com/mitre/inspec_tools/issues/15)
- check /examples/sample\_json to see if any of the results are sensitive [\#14](https://github.com/mitre/inspec_tools/issues/14)

**Merged pull requests:**

- replaced docsplit with pdf-reader [\#43](https://github.com/mitre/inspec_tools/pull/43) ([robthew](https://github.com/robthew))
- Updated remove dir statement [\#41](https://github.com/mitre/inspec_tools/pull/41) ([robthew](https://github.com/robthew))
- Added appveyor config [\#40](https://github.com/mitre/inspec_tools/pull/40) ([robthew](https://github.com/robthew))
- Travis test [\#39](https://github.com/mitre/inspec_tools/pull/39) ([robthew](https://github.com/robthew))
- Add rubocop to the process [\#35](https://github.com/mitre/inspec_tools/pull/35) ([aaronlippold](https://github.com/aaronlippold))
- \* added refernces to external data sources [\#30](https://github.com/mitre/inspec_tools/pull/30) ([aaronlippold](https://github.com/aaronlippold))

## [v1.1.2](https://github.com/mitre/inspec_tools/tree/v1.1.2) (2018-11-08)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.1.1...v1.1.2)

## [v1.1.1](https://github.com/mitre/inspec_tools/tree/v1.1.1) (2018-11-08)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.1.0...v1.1.1)

## [v1.1.0](https://github.com/mitre/inspec_tools/tree/v1.1.0) (2018-11-08)
[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.0.0...v1.1.0)

**Fixed bugs:**

- Remove unneeded `exe` dir if we are going to standardize on `bin`and update the `.gemspec` file [\#25](https://github.com/mitre/inspec_tools/issues/25)

**Closed issues:**

- when you When build the gem and install it - the command `inspec\_tools` does not seem to install into the path [\#26](https://github.com/mitre/inspec_tools/issues/26)
- Add MITRE Copyright to the end of the README.md [\#23](https://github.com/mitre/inspec_tools/issues/23)
- Update email addresses to MITRE addresses [\#18](https://github.com/mitre/inspec_tools/issues/18)
- update readme.md [\#17](https://github.com/mitre/inspec_tools/issues/17)
- update inspec\_tools.gemspec [\#16](https://github.com/mitre/inspec_tools/issues/16)
- update license to apache 2.0 [\#13](https://github.com/mitre/inspec_tools/issues/13)
- Separate Files defaults to \[False\] [\#10](https://github.com/mitre/inspec_tools/issues/10)
- Rename repository to 'inspec\_tools' [\#9](https://github.com/mitre/inspec_tools/issues/9)

**Merged pull requests:**

- Cleanup Debug Statetements [\#12](https://github.com/mitre/inspec_tools/pull/12) ([yarick](https://github.com/yarick))
- Change default separated\_files setting to default to true [\#11](https://github.com/mitre/inspec_tools/pull/11) ([yarick](https://github.com/yarick))
- Cleanup [\#8](https://github.com/mitre/inspec_tools/pull/8) ([robthew](https://github.com/robthew))
- Unification [\#5](https://github.com/mitre/inspec_tools/pull/5) ([dromazmj](https://github.com/dromazmj))
- \* Adds functionality for inspec2csv [\#4](https://github.com/mitre/inspec_tools/pull/4) ([dromazmj](https://github.com/dromazmj))
- Md/pdf [\#3](https://github.com/mitre/inspec_tools/pull/3) ([dromazmj](https://github.com/dromazmj))
- Md/csv2inspec [\#2](https://github.com/mitre/inspec_tools/pull/2) ([dromazmj](https://github.com/dromazmj))
- Writes code in the inspec util to output an inspec json to a directory [\#1](https://github.com/mitre/inspec_tools/pull/1) ([dromazmj](https://github.com/dromazmj))



\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*