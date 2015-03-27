raw-github
===

Creates a simple local proxy for `raw.githubusercontent.com` and makes both public private repository raw files available via the same domain and url structure.

This was created to temporarily work around a [clib](https://github.com/clibs/clib) limitation ( [#107](https://github.com/clibs/clib/issues/107), [#105](https://github.com/clibs/clib/issues/105), [#51](https://github.com/clibs/clib/issues/107)) because of which right now you can only use public github repositories as [clib dependencies](https://github.com/clibs/clib/wiki/Explanation-of-package.json#dependencies).

Until clib is improved to allow private Github repos, the below, admitedly clunky, setup can help you develop clib enabled libraries for you internal projects. 

Setup
---
With a recent version of ruby and the [bundler](http://bundler.io/) gem installed, clone this repo and run:
````
bundle install
````

This will install the ruby libraries (specified in our Gemfile) that we're using to run this proxy.

To authenticate with the Github API create a Github [Personal Access Token](https://github.com/settings/applications) with `repo` access.

To start the proxy run the following command, replace `<token>` with your [Personal Access Token](https://github.com/settings/applications)

````
GITHUB_ACCESS_TOKEN=<token> \
  bundle exec thin \
    --rackup config.ru \
    --port 3000 \
    start
````

This will make raw files from github repositories (public and private) available on a local web server running at `localhost:3000`, for example `http://localhost:3000/clibs/list/master/package.json`

Now redirect all requests intended for `raw.githubusercontent.com` to `localhost:3000`. On MacOS you can set this up as follows (the same should be possible on Linux with ipconfig).

````
sudo ifconfig lo0 10.0.0.1 alias
sudo ipfw add fwd 127.0.0.1,3000 tcp from me to 10.0.0.1 dst-port 80
echo '10.0.0.1  raw.githubusercontent.com' | sudo tee -a /etc/hosts
````

Finally, the current version of clib requests raw files from Github using HTTP**S** `https://raw.githubusercontent.com` and not HTTP. Normally, this is great but it would've been a lot more work to support HTTPS in this proxy so I've [forked clib](https://github.com/mrinalwadhwa/clib) with a [minor change](https://github.com/clibs/clib/compare/master...mrinalwadhwa:master?diff=split&name=master) to request via HTTP. [Compile and use](https://github.com/clibs/clib#installation) this forked version of clib to benefit from this proxy.
