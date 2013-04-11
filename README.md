cg: config getter
=================

Status
------
`cg` is a statically configured, hard-coded config getter.  It
allows you to assign certain "configuration spaces" to your project.
Within your project, you can query `cg` to get service values
appropriate to your current configuration space.

`cg` is great for simple deployments where you have different
services available in development, staging, and production without
cluttering your code with independent checks.

Usage
-----
### Configuration
We have two configuration syntaxes.  One is very explicit
with proplists and the other just has name/value pairs.

We have "configuration spaces" such as dev, prod, test, matt-laptop, etc.

Under a configuration space we have individual services with up to three
settings: host, port, and limit.
If you only need one value per service, you can omit the proplist after
your service and use a value directly.

`cg` automatically discovers which configuration space to use based on
the directory of your application.  If your directory name
has a dash in it, everything after the first dash becomes your configuration
space.  e.g. if your application directory is `foobar-megaproduction` then your
configuration space will be the atom `megaproduction`.  If your application
directory doesn't have a dash, the configuration space defaults
to `dev`.

To get started, set your configuration in an application.
For example, if your application is `foobar`,
put the following in `foobar.config` for the explicit syntax:

    {cg, [
      {dev, [
       {riak_chatty, [
        {host, "foo"},
        {port, 3333},
        {limit, 12}
       ]}
      ]},
      {beta, [
       {riak_chatty, [
        {host, "boo"},
        {port, 2221},
        {limit, 3640}
       ]}
      ]}
     ]}

OR -

You can also use the compact syntax of:

     {cg, [
      {dev, [
       {beas,         6381},
       {bess,         6381}
      ]},
      {beta, [
       {beas,         5081},
       {bess,         5085}
      ]}
     ]}

With your config set, you can start grabbing config values
in your application.  In your `foobar_app.erl` `start/2`,
start cg with `application:start(cg)`.  Now you have access
to all your cg definitions.

You can discover your current configuration space with
`cg:use_space()` which returns the atom of your current
configuration space (dev by default, or the after-dash
values in your application directory).

You can get individual service values by using `cg:port/1`,
`cg:host/1` or `cg:limit/1` with the only argument being
the service you want to retrieve.  Since `cg` knows
your existing configuration space, when you ask for a
service value the correct match is returned from your
configuration space (if everything is set up correctly).

If you're using the sparse config syntax, you can use
any of the three value extractors (port, host, limit)
to get your value.


Extended example:

    {cg, [
     {dev, [
      {stripe, "DEV API KEY"},
      {redis, 6631},
      {riak, 2211}
     ]},
     {prod, [
      {stripe, "PROD API KEY"},
      {redis, 6699},
      {riak, 2299}
     ]}
    ]}.

    application:start(cg),
    application:set_env(stripe, auth_token, cg:limit(stripe)), % slight abuse of an extractor name, but it works
    start_supervisor(redis, cg:port(redis)),
    start_supervisor(riak, cg:port(riak)).

Building
--------
        rebar get-deps
        rebar compile

Testing
-------
(Note: no tests exist as of right now.
The test suite is a dummy template for dummies.)

        rebar eunit skip_deps=true suite=cg

Next Steps
----------
Ideally this would be a distributed instantly-notifying pubsub configuration
thinggy, but we don't need that yet.

Contributions
-------------
Want to help?  Patches welcome.
