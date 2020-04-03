# Changelog

## [Unreleased](https://github.com/mitre/inspec_tools/tree/HEAD)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v2.0.1.pre2...HEAD)

**Merged pull requests:**

- Cleanup xlsx2inspec Process of Adding NIST and CIS Controls to Inspec Controls [\#127](https://github.com/mitre/inspec_tools/pull/127) ([Bialogs](https://github.com/Bialogs))

## [v2.0.1.pre2](https://github.com/mitre/inspec_tools/tree/v2.0.1.pre2) (2020-04-02)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v2.0.1.pre1...v2.0.1.pre2)

**Merged pull requests:**

- Missed some references to inspec/objects [\#126](https://github.com/mitre/inspec_tools/pull/126) ([Bialogs](https://github.com/Bialogs))
- Move to mitre/inspec-objects [\#125](https://github.com/mitre/inspec_tools/pull/125) ([Bialogs](https://github.com/Bialogs))

## [v2.0.1.pre1](https://github.com/mitre/inspec_tools/tree/v2.0.1.pre1) (2020-04-02)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v2.0.0...v2.0.1.pre1)

**Merged pull requests:**

- Pull lfs objects in when building the gem. [\#124](https://github.com/mitre/inspec_tools/pull/124) ([rbclark](https://github.com/rbclark))

## [v2.0.0](https://github.com/mitre/inspec_tools/tree/v2.0.0) (2020-04-01)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.10...v2.0.0)

**Fixed bugs:**

- xlsx2inspec failing to parse controls over two digits [\#117](https://github.com/mitre/inspec_tools/issues/117)

**Merged pull requests:**

- Update parse XLSXTool\#parse\_cis\_control to handle the case when there… [\#123](https://github.com/mitre/inspec_tools/pull/123) ([Bialogs](https://github.com/Bialogs))
- Track Inspec versions \>= 4.18.100 [\#122](https://github.com/mitre/inspec_tools/pull/122) ([Bialogs](https://github.com/Bialogs))
- Restructure workflow for publishing gem [\#121](https://github.com/mitre/inspec_tools/pull/121) ([rbclark](https://github.com/rbclark))

## [v1.8.10](https://github.com/mitre/inspec_tools/tree/v1.8.10) (2020-03-30)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.9...v1.8.10)

**Merged pull requests:**

- added two digit contol parsing fixes \#117 [\#120](https://github.com/mitre/inspec_tools/pull/120) ([yarick](https://github.com/yarick))

## [v1.8.9](https://github.com/mitre/inspec_tools/tree/v1.8.9) (2020-03-30)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.8...v1.8.9)

**Merged pull requests:**

- Fix bug in creating severity override guidance tags [\#118](https://github.com/mitre/inspec_tools/pull/118) ([Bialogs](https://github.com/Bialogs))

## [v1.8.8](https://github.com/mitre/inspec_tools/tree/v1.8.8) (2020-03-30)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.7...v1.8.8)

**Implemented enhancements:**

- add a `--json-full` and `--json-counts` option to the summary command - like the cli so I can pipe to jq [\#78](https://github.com/mitre/inspec_tools/issues/78)

**Merged pull requests:**

- Add --json-full and --json-summary options to summary subcommand [\#116](https://github.com/mitre/inspec_tools/pull/116) ([Bialogs](https://github.com/Bialogs))

## [v1.8.7](https://github.com/mitre/inspec_tools/tree/v1.8.7) (2020-03-29)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.6...v1.8.7)

## [v1.8.6](https://github.com/mitre/inspec_tools/tree/v1.8.6) (2020-03-27)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.5...v1.8.6)

**Closed issues:**

- GitHub Actions Build Matrix [\#112](https://github.com/mitre/inspec_tools/issues/112)

**Merged pull requests:**

- Update build/test process to only use GitHub actions [\#115](https://github.com/mitre/inspec_tools/pull/115) ([Bialogs](https://github.com/Bialogs))

## [v1.8.5](https://github.com/mitre/inspec_tools/tree/v1.8.5) (2020-03-27)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.4...v1.8.5)

**Implemented enhancements:**

- add "\# encoding: utf-8" to controls [\#54](https://github.com/mitre/inspec_tools/issues/54)

**Merged pull requests:**

- Add '\# encoding: UTF-8' to the top of all generated controls/\*.rb [\#114](https://github.com/mitre/inspec_tools/pull/114) ([Bialogs](https://github.com/Bialogs))

## [v1.8.4](https://github.com/mitre/inspec_tools/tree/v1.8.4) (2020-03-27)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.3...v1.8.4)

**Fixed bugs:**

- \[BUG\] inspec\_tools \> 1.7.1 getting unknown encoding name -  UTF-8 \(RuntimeError\) [\#110](https://github.com/mitre/inspec_tools/issues/110)

**Merged pull requests:**

- Reorganize overrides [\#113](https://github.com/mitre/inspec_tools/pull/113) ([Bialogs](https://github.com/Bialogs))

## [v1.8.3](https://github.com/mitre/inspec_tools/tree/v1.8.3) (2020-03-27)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.2...v1.8.3)

**Merged pull requests:**

- Spaces cause interpreter not to pick up encoding correctly [\#111](https://github.com/mitre/inspec_tools/pull/111) ([Bialogs](https://github.com/Bialogs))

## [v1.8.2](https://github.com/mitre/inspec_tools/tree/v1.8.2) (2020-03-25)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.1...v1.8.2)

**Merged pull requests:**

- Gemspec Dependency Updates  [\#109](https://github.com/mitre/inspec_tools/pull/109) ([Bialogs](https://github.com/Bialogs))

## [v1.8.1](https://github.com/mitre/inspec_tools/tree/v1.8.1) (2020-03-24)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.8.0...v1.8.1)

**Closed issues:**

- Please update the homepage in the gemspec to point to inspec-tools.mitre.org [\#105](https://github.com/mitre/inspec_tools/issues/105)

**Merged pull requests:**

- Update Gem homepage to https://inspec-tools.mitre.org/ [\#108](https://github.com/mitre/inspec_tools/pull/108) ([Bialogs](https://github.com/Bialogs))

## [v1.8.0](https://github.com/mitre/inspec_tools/tree/v1.8.0) (2020-03-24)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.7.3...v1.8.0)

**Closed issues:**

- csv2inspec impact doesn't correct format "CAT I II III" severities [\#88](https://github.com/mitre/inspec_tools/issues/88)

**Merged pull requests:**

- Support conversion from CAT/Category style severities when generating an impact number. [\#106](https://github.com/mitre/inspec_tools/pull/106) ([Bialogs](https://github.com/Bialogs))

## [v1.7.3](https://github.com/mitre/inspec_tools/tree/v1.7.3) (2020-03-23)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.7.2...v1.7.3)

**Merged pull requests:**

- Hotfix [\#104](https://github.com/mitre/inspec_tools/pull/104) ([Bialogs](https://github.com/Bialogs))

## [v1.7.2](https://github.com/mitre/inspec_tools/tree/v1.7.2) (2020-03-23)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.7.1...v1.7.2)

**Implemented enhancements:**

- add warning in CLI if needed app is missing for pdf2inspec  [\#38](https://github.com/mitre/inspec_tools/issues/38)

**Merged pull requests:**

- Allow pushing to any gem host to support GitHub [\#103](https://github.com/mitre/inspec_tools/pull/103) ([Bialogs](https://github.com/Bialogs))

## [v1.7.1](https://github.com/mitre/inspec_tools/tree/v1.7.1) (2020-03-23)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.7.0...v1.7.1)

**Merged pull requests:**

- GitHub Action Workflow Updates [\#102](https://github.com/mitre/inspec_tools/pull/102) ([Bialogs](https://github.com/Bialogs))

## [v1.7.0](https://github.com/mitre/inspec_tools/tree/v1.7.0) (2020-03-20)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.21...v1.7.0)

**Implemented enhancements:**

- Migrate to depend on the new inspect objects library [\#86](https://github.com/mitre/inspec_tools/issues/86)

**Merged pull requests:**

- Remove warnings \(\#minor\) [\#101](https://github.com/mitre/inspec_tools/pull/101) ([Bialogs](https://github.com/Bialogs))

## [v1.6.21](https://github.com/mitre/inspec_tools/tree/v1.6.21) (2020-03-20)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.20...v1.6.21)

**Implemented enhancements:**

- Parse cis XSLX [\#90](https://github.com/mitre/inspec_tools/pull/90) ([lukemalinowski](https://github.com/lukemalinowski))

**Closed issues:**

- figure out rubygems.org [\#31](https://github.com/mitre/inspec_tools/issues/31)

## [v1.6.20](https://github.com/mitre/inspec_tools/tree/v1.6.20) (2020-03-17)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.19...v1.6.20)

**Merged pull requests:**

- Rubygems release workflow [\#100](https://github.com/mitre/inspec_tools/pull/100) ([Bialogs](https://github.com/Bialogs))

## [v1.6.19](https://github.com/mitre/inspec_tools/tree/v1.6.19) (2020-03-16)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.18...v1.6.19)

**Merged pull requests:**

- Update github workflows [\#99](https://github.com/mitre/inspec_tools/pull/99) ([Bialogs](https://github.com/Bialogs))

## [v1.6.18](https://github.com/mitre/inspec_tools/tree/v1.6.18) (2020-03-16)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.17...v1.6.18)

## [v1.6.17](https://github.com/mitre/inspec_tools/tree/v1.6.17) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.16...v1.6.17)

**Fixed bugs:**

- Fix VERSION file update to update the right file in the gem [\#79](https://github.com/mitre/inspec_tools/issues/79)

## [v1.6.16](https://github.com/mitre/inspec_tools/tree/v1.6.16) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.15...v1.6.16)

**Fixed bugs:**

- The `changelog.md` versions seem to be broken [\#80](https://github.com/mitre/inspec_tools/issues/80)
- Update version.yml regex to match multidigit version numbers and use … [\#98](https://github.com/mitre/inspec_tools/pull/98) ([Bialogs](https://github.com/Bialogs))

## [v1.6.15](https://github.com/mitre/inspec_tools/tree/v1.6.15) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.14...v1.6.15)

**Merged pull requests:**

- Fix issue with CHANGELOD.md not generating because of invalid startin… [\#97](https://github.com/mitre/inspec_tools/pull/97) ([Bialogs](https://github.com/Bialogs))

## [v1.6.14](https://github.com/mitre/inspec_tools/tree/v1.6.14) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.13...v1.6.14)

**Closed issues:**

- add travis to the commit/PR workflow [\#36](https://github.com/mitre/inspec_tools/issues/36)

**Merged pull requests:**

- Use my personal version of github-actions-x/commit until git-lfs patc… [\#96](https://github.com/mitre/inspec_tools/pull/96) ([Bialogs](https://github.com/Bialogs))

## [v1.6.13](https://github.com/mitre/inspec_tools/tree/v1.6.13) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.12...v1.6.13)

**Closed issues:**

- use github\_changelog\_generator in our release process [\#33](https://github.com/mitre/inspec_tools/issues/33)
- add project instructions for Changelog, contribution and issue\_template [\#32](https://github.com/mitre/inspec_tools/issues/32)

**Merged pull requests:**

- Enable git-lfs for this repository; tracking xls and xlsx files. [\#94](https://github.com/mitre/inspec_tools/pull/94) ([Bialogs](https://github.com/Bialogs))

## [v1.6.12](https://github.com/mitre/inspec_tools/tree/v1.6.12) (2020-03-13)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.11...v1.6.12)

**Closed issues:**

- Typo in main README.md [\#89](https://github.com/mitre/inspec_tools/issues/89)

**Merged pull requests:**

- Fix typo in README.md, Remove development guidance in favor of a wiki… [\#93](https://github.com/mitre/inspec_tools/pull/93) ([Bialogs](https://github.com/Bialogs))

## [v1.6.11](https://github.com/mitre/inspec_tools/tree/v1.6.11) (2020-03-12)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.10...v1.6.11)

**Closed issues:**

- DISA STIG web address needs to be updated [\#66](https://github.com/mitre/inspec_tools/issues/66)

**Merged pull requests:**

- Ignore debug generated files [\#92](https://github.com/mitre/inspec_tools/pull/92) ([Bialogs](https://github.com/Bialogs))

## [v1.6.10](https://github.com/mitre/inspec_tools/tree/v1.6.10) (2020-03-12)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.9...v1.6.10)

**Fixed bugs:**

- Fix https://public.cyber.mil refernces [\#81](https://github.com/mitre/inspec_tools/pull/81) ([aaronlippold](https://github.com/aaronlippold))

## [v1.6.9](https://github.com/mitre/inspec_tools/tree/v1.6.9) (2020-03-06)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.8...v1.6.9)

## [v1.6.8](https://github.com/mitre/inspec_tools/tree/v1.6.8) (2020-03-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.7...v1.6.8)

## [v1.6.7](https://github.com/mitre/inspec_tools/tree/v1.6.7) (2020-02-11)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.6...v1.6.7)

## [v1.6.6](https://github.com/mitre/inspec_tools/tree/v1.6.6) (2020-02-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/53bdcb3...v1.6.6)

**Fixed bugs:**

- --help option is broken but inspec\_tools help \<command\> works [\#77](https://github.com/mitre/inspec_tools/issues/77)
- Fixes \#77 by shifting help commands around [\#87](https://github.com/mitre/inspec_tools/pull/87) ([lukemalinowski](https://github.com/lukemalinowski))

**Merged pull requests:**

- Apply fixes from CodeFactor [\#82](https://github.com/mitre/inspec_tools/pull/82) ([aaronlippold](https://github.com/aaronlippold))

## [53bdcb3](https://github.com/mitre/inspec_tools/tree/53bdcb3) (2019-11-06)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.4...53bdcb3)

**Fixed bugs:**

- --version and -v are broken [\#76](https://github.com/mitre/inspec_tools/issues/76)

**Closed issues:**

- Logic fix [\#83](https://github.com/mitre/inspec_tools/issues/83)

**Merged pull requests:**

- Fixes \#83 [\#85](https://github.com/mitre/inspec_tools/pull/85) ([aaronlippold](https://github.com/aaronlippold))
- Fixes \#76 by editing version number [\#84](https://github.com/mitre/inspec_tools/pull/84) ([lukemalinowski](https://github.com/lukemalinowski))

## [v1.6.4](https://github.com/mitre/inspec_tools/tree/v1.6.4) (2019-11-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.3...v1.6.4)

## [v1.6.3](https://github.com/mitre/inspec_tools/tree/v1.6.3) (2019-11-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.5...v1.6.3)

## [v1.6.5](https://github.com/mitre/inspec_tools/tree/v1.6.5) (2019-11-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.2...v1.6.5)

## [v1.6.2](https://github.com/mitre/inspec_tools/tree/v1.6.2) (2019-11-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.1...v1.6.2)

## [v1.6.1](https://github.com/mitre/inspec_tools/tree/v1.6.1) (2019-11-05)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.6.0...v1.6.1)

**Merged pull requests:**

- Update Profile logic include control exceptions [\#75](https://github.com/mitre/inspec_tools/pull/75) ([rx294](https://github.com/rx294))
- Null Byte in json report causes inspec2ckl to bomb-out [\#73](https://github.com/mitre/inspec_tools/pull/73) ([kevin-j-smith](https://github.com/kevin-j-smith))

## [v1.6.0](https://github.com/mitre/inspec_tools/tree/v1.6.0) (2019-10-04)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.5.0...v1.6.0)

**Closed issues:**

- Updated logic for results metrics [\#74](https://github.com/mitre/inspec_tools/issues/74)

## [v1.5.0](https://github.com/mitre/inspec_tools/tree/v1.5.0) (2019-09-10)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.4.2...v1.5.0)

**Closed issues:**

- Feature Enhancement: Inspec command plugin for inspec\_tools [\#67](https://github.com/mitre/inspec_tools/issues/67)

**Merged pull requests:**

- Kevin j smith adding inspec command plugin logic [\#72](https://github.com/mitre/inspec_tools/pull/72) ([lukemalinowski](https://github.com/lukemalinowski))
- Added logic so that inspec\_tools can be a plugin to Inspec as a comma… [\#68](https://github.com/mitre/inspec_tools/pull/68) ([kevin-j-smith](https://github.com/kevin-j-smith))

## [v1.4.2](https://github.com/mitre/inspec_tools/tree/v1.4.2) (2019-07-30)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.4.1...v1.4.2)

**Closed issues:**

- Add additional option for Summary command [\#64](https://github.com/mitre/inspec_tools/issues/64)
- `insert\_json\_metadata': undefined method `version' for nil:NilClass [\#63](https://github.com/mitre/inspec_tools/issues/63)

**Merged pull requests:**

- Updated rake version [\#69](https://github.com/mitre/inspec_tools/pull/69) ([robthew](https://github.com/robthew))
- Add in 'inspec' and 'fileutils' require statements [\#65](https://github.com/mitre/inspec_tools/pull/65) ([samcornwell](https://github.com/samcornwell))

## [v1.4.1](https://github.com/mitre/inspec_tools/tree/v1.4.1) (2019-06-20)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.4.0...v1.4.1)

## [v1.4.0](https://github.com/mitre/inspec_tools/tree/v1.4.0) (2019-05-17)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.3.6...v1.4.0)

**Merged pull requests:**

- Apply fixes from CodeFactor [\#61](https://github.com/mitre/inspec_tools/pull/61) ([aaronlippold](https://github.com/aaronlippold))

## [v1.3.6](https://github.com/mitre/inspec_tools/tree/v1.3.6) (2019-05-02)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.3.5...v1.3.6)

**Implemented enhancements:**

- document new metadata.json file and creation of file in README.md [\#53](https://github.com/mitre/inspec_tools/issues/53)
- remove 'severity' from conversion [\#57](https://github.com/mitre/inspec_tools/pull/57) ([aaronlippold](https://github.com/aaronlippold))

**Closed issues:**

- While working with STIGViewer there were some missing TAGs [\#50](https://github.com/mitre/inspec_tools/issues/50)
- remove severity tag in xccdf to inspec converted [\#44](https://github.com/mitre/inspec_tools/issues/44)

## [v1.3.5](https://github.com/mitre/inspec_tools/tree/v1.3.5) (2019-05-01)

[Full Changelog](https://github.com/mitre/inspec_tools/compare/v1.3.4...v1.3.5)

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

[Full Changelog](https://github.com/mitre/inspec_tools/compare/85b69b32277ea43f95b09eee00e9f7b84c62dfff...v1.1.0)

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



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
