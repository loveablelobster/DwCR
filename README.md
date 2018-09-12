# DwCR
DwCA in a SQLite database complete with
[Sequel](https://github.com/jeremyevans/sequel) models.

## Command Line Tool

### Create a new DwCR file

From within the directory of a DwC Archive:

```ruby
dwcr new -t dwcr-test.db
```

will create the file in the directory, named after the directory

see `dwcr new --help` for options

### Load an existing DwCR file

```ruby
dwcr load ~/documents/dwca/dwcr-test.db
```

