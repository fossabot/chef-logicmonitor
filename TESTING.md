Testing
=======

This cookbook includes both unit tests via [ChefSpec](https://github.com/sethvargo/chefspec) and integration tests via [Test Kitchen](https://github.com/test-kitchen/test-kitchen).

Setting up the test environment
-------------------------------

Install the latest version of [Docker](https://www.docker.com/get-docker).

The Chef tooling (chefspec/test kitchen/etc) can be managed by the [Chef Development Kit](http://downloads.getchef.com/chef-dk/) or by RVM/Bundler.

Clone the latest version of the cookbook from the repository.

```bash
git clone git@github.com:Granicus/chef-logicmonitor.git
cd chef-logicmonitor
```

Running ChefSpec
----------------

ChefSpec unit tests are located in `spec`. Each recipe has a `recipename_spec.rb` file that contains unit tests for that recipe. Your new functionality or bug fix should have corresponding test coverage - if it's a change, make sure it doesn't introduce a regression (existing tests should pass). If it's a change or introduction of new functionality, add new tests as appropriate.

To run ChefSpec for the whole cookbook:

`chef exec rspec`

To run ChefSpec for a specific recipe:

`chef exec rspec spec/unit/recipes/default_spec.rb`

Running Test Kitchen
--------------------

Test Kitchen test suites are defined in [.kitchen.yml](https://github.com/Granicus/chef-logicmonitor/blob/master/.kitchen.yml). Running `kitchen test` will cause Test Kitchen to run the `logicmonitor::default` recipe. If the Chef run completes successfully, corresponding tests in `test/smoke` are executed. These must also pass.
