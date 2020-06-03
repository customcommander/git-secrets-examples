# git-secrets examples

Various examples on how to use [git-secrets][gs-repo] to detect secrets in your current source tree and your history.

This is the canonical source for this post of mine:<br>
https://softwarerecs.stackexchange.com/q/74761/67727

## Try This Yourself

All the _How Tos_ below have been verified against a reproducible Dockerised environment.

Clone this repository and simply execute `./run.sh` (assuming you have Docker installed on your machine).

The Docker container has `git-secrets` installed in addition to a few Git repositories to experiment with.

## How Tos

### How To Install?

Fetch the latest release, unzip it and build it with Make.
The `git-secrets` binary should now be in your PATH. e.g.,

```sh
curl -L -o /tmp/git-secrets.zip https://github.com/awslabs/git-secrets/archive/1.3.0.zip
cd /tmp
unzip git-secrets.zip
cd git-secrets-1.3.0
make install
```

You're not done yet! It now must be installed as a Git hook in each Git repository you would like to inspect. e.g.,

```sh
cd /path/to/repo
git-secrets --install
```

_From now on the following How Tos will assume that `git-secrets` is in your PATH and that the Git hook has been installed_

### How To Find Secrets In A Git Repository?

We'll be looking for the following patterns:

- token
- username
- password

We want to know which files match these patterns in the current source tree and across the entire Git history.

To demonstrate the capabilities of `git-secrets` will add the first pattern from the CLI:

```sh
# at the root of the repo
git secrets --add token
```

The two other patterns will be loaded from a file `/var/forbidden-patterns.txt`:

```txt
username
password
```

```sh
# at the root of the repo
git secrets --add-provider -- cat /var/forbidden-patterns.txt
```

Now let's add the following files to our Git repo:

First `secrets-1.txt`:

```
username=abc
password=123
```

```sh
# at the root of your repo
git add secrets-1.txt
git commit -m "add secrets-1.txt"
# please note that we're now removing the file!
git rm secrets-1.txt
git commit -m "remove secrets-1.txt"
```

Then `secrets-2.txt`:

```
token=123456789
```

```sh
# at the root of your repo
git add secrets-2.txt
git commit -m "add secrets-2.txt"
```

Now let's scan the current source tree:

```sh
# at the root of your repo
git secrets --scan
```

Which outputs:

```txt
secrets-2.txt:1:token=123456789
```

It hasn't found `secrets-1.txt` because that file has been deleted. However we also want to make sure we're not exposing secrets in the Git history. Let's do that:

```sh
git secrets --scan-history
```

Which outputs:

```txt
c5e7f9887ed95f7d3aeb4ed011a8235e238b9ed1:secrets-2.txt:1:token=123456789
c0082ddbb0e2b14499808b376e133a6fbb5799cc:secrets-1.txt:1:username=abc
c0082ddbb0e2b14499808b376e133a6fbb5799cc:secrets-1.txt:2:password=123
```

We now can see in which commits a secret has been found.





[gs-repo]: https://github.com/awslabs/git-secrets