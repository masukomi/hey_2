# hey

TODO: Write a description here

## Installation

TODO: Write installation instructions here

## Usage

TODO: Write usage instructions here

## Development

### Writing Custom reports
Writing custom reports is pretty easy. Your report needs to be an executable
that can respond to two sets of arguments:

```
your_report --info
# and 
your_report -d path/to/hey.db
```

The info request should write a JSON object to standard out. It must contain the
following keys and values:

```
name: the name of your report
      This should not contain spaces as it is what people 
      will use to tell Hey! to run your report
description: a description of your report
db_version: the minimum version of the 
            hey db you support (currently we're at "2.0")
```

Example Info:

```
{"name":"test_report","description":"just a test.","db_version":"2.0"}
```

When a user runs `hey report` a listing of all the reports will be output,
including the information you've provided in the `--info` json.

In this case you would say `hey report test_report` (because `test_report`
is it's name) to run that test report.

**The other request**, with a path to the database is what is called when
someone runs the report (`hey report test_report`) It can do whatever you want it to.
There are no restrictions. Hey will just call it and assume it does what it's
intended to do.

Once you've created your report just put it in this directory: 
`~/.config/hey/reports/` and Hey! will take care of the rest.


## Contributing

1. Fork it ( https://github.com/[your-github-name]/hey/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [[your-github-name]](https://github.com/[your-github-name]) masukomi - creator, maintainer
