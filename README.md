# cheatr

Cheatr is a simple command line utility to access cheat sheets from an online
repository.

Generally speaking, cheatr is a tool that allows to host an online collection
of cheat sheets, and lets users query and maintain this repository remotely via
a command line client utility.

### What is a cheat sheet?

In the context of cheatr, a cheat sheet is a small document with quick tips and
hints on a concrete and specific topic.  Typically it contains notes intended
to aid one's memory, like listing common and useful shortcuts used on a
program, quick and easy tips on how to use a library, or the command line
options of a shell command, for instance.

Cheatr however enforces very little on the contents of the cheat sheets in a
repository.  The above specification is just a guideline on the intended use of
this tool, but in practice you can use it to store and maintain any collection
of text documents in it.

Further down this document you'll find more information about the format of
[cheat sheet contents](#cheat-sheet-contents).

## Installation

    $ gem install cheatr

## Usage

Cheatr retrieves cheat sheets from a remote server, so we need to tell cheatr
where to look.

    $ cheatr config server cheatr.gnapse.com

This generates a configuration file in `~/.cheatr/config.yml`.  Now we can
start querying the remote server for cheat sheets, or start creating new ones.

    $ cheatr show "ruby*"  # Cheat sheets with names starting with 'ruby'
    ruby.strings
    ruby.blocks
    rubygems

    $ cheatr search ruby   # With this command you can ommit the wildcard
    ruby.strings
    ruby.blocks
    rubygems

    $ cheatr all           # Lists all cheat sheets available
    ack
    bash
    cplusplus
    ...
    ruby
    vim
    zsh

Tell cheatr to show a given cheat sheet.

    $ cheatr show ruby.blocks
    Ruby blocks are an awesome language feature!

The contents of a cheat sheet are cached once it has been fetched.  You can
force cheatr to fetch remote contents.

    $ cheatr show ruby.blocks -r

You can edit existing cheat sheets, or create new ones.

    $ cheatr edit ruby.blocks

This will launch you preferred `$EDITOR` with the current contents of the
specified cheat sheet.  After you save the file and quit the editor, `cheatr`
will update the cheat sheet contents.

Cheatr commands provide help, so you can discover all its features and
possibilities. Type `cheatr --help` or `cheatr <command> --help` for details.

## Web server

This gem includes the server side component as well, so anyone can host their
own cheat sheets service.  This server offers the basic API-like calls to
query, retrieve and modify cheat sheet contents.  You can start a cheatr server
with the following command:

    $ cheatr server /path/to/cheatr/repository

The repository path refers to the location where the cheats repository can be
found.  A cheatr repository is nothing more than a git repository holding the
cheat sheets as files in it.  If omitted, the current working directory is
assummed.

A cheatr server is a [sinatra][] app, so it can also be started using [rack][].
Every cheatr repository, when created, is initialized with a standard
`config.ru` file.  So while placed in the repository's root folder, the server
can be started with the following command:

    $ rackup

Also try `rackup --help` for more options.

[sinatra]: http://www.sinatrarb.com
[rack]: https://github.com/rack/rack

### Web interface

Additionally, cheatr servers can be accessed directly on a browser, where
content is delivered as traditional hyperlinked web pages instead of mere plain
text, with the possibility to search for cheat sheets, or [link between
them](#cheat-sheet-hyperlinks), converting cheatr in a simple but powerful
cheat sheets wiki.

To try this, type the following command:

    $ cheatr browse ruby.blocks

It will open the contents of the specified cheat sheet in your preferred
browser.  Or you can always type the URLs in your browser yourself, provided
you know the cheatr server you want to access.

## Cheat sheet contents

Although cheatr does not enforce any format to the contents of cheat sheets,
it assumes they consist of markdown text.  Thus is highly beneficial to adhere
to this convention, and embrace it.

### Cheat sheet hyperlinks

In addition to standard markdown syntax, cheatr supports a minor custom
extension, that becomes useful when browsing a cheatr server in a web browser.
This is related to linking in between cheat sheets, as hinted in the previous
section.

This is best shown with an example.

```
Dynamic languages, like {{ruby}} and {{python}}, are more versatile than
{{c++|cplusplus}} in many situations.
```

Noticed the slices of text surrounded by doble braces?  These are cheatr
hyperlinks.  When showing pages through the web interface in a browser, these
will be converted to links to the appropriate cheat sheet.

Note also the link to the `cplusplus` cheat sheet.  The text before the
vertical bar will be used as the link text, whereas the text after it is the
name of the cheat sheet to link to.

In the command line, these "links" will be shown unmodified, still serving the
purpose of discovery, because the user can identify these "links" and discover
new related topics to continue "browsing" and learning.

## Contributing

Feel free to dive into the code to understand more about how cheatr works, or
just for fun.  Please note that this is a very young project with very rough
edges still.  Issue reports, feature and design suggestions, as well as pull
requests, are all welcome!

In case you decide to step in:

1. Fork the repo (`git clone https://github.com/gnapse/cheatr.git`)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

And don't forget to take a look at the [open issues][] in case you need some
inspiration on what to work on.

[open issues]: https://github.com/gnapse/cheatr/issues

## Thanks

Thanks to [defunkt][] for [cheat][], which provided the idea for this project.

[defunkt]: https://github.com/defunkt
[cheat]: https://github.com/defunkt/cheat
