
# kpm Scripts

The Koding Package Manager is a binary *(the `kpm` bin)*, and a 
series of installation and removal scripts. The scripts install programs 
and frameworks with as minimal setup as possible, making them *entirely* 
beginner friendly.

This document and repository are mainly for developers of the Installer 
Scripts that the Koding Package Manager uses. If you're looking for a 
beginner friendly installation and usage guide, [click here][user guide].

## Installing the Bin

To install the bin, run the following command.

```text
curl -sSL learn.koding.com/kpm.sh | sh
```

For more detailed instructions, see the [user guide][user guide].

## Installing Packages

Packages can be listed and installed with the following commands.

```text
kpm list
kpm install PACKAGENAME
```

For more detailed instructions, see the [user guide][user guide].

## Writing Scripts

You can add an Installer and Uninstaller script for just about anything.  
Simply make a pull request against this repo and placing your script into 
a new folder with the name of your script, eg `./scriptname` *(where 
`scriptname` is the name of your script)*, and name the script 
`./scriptname/installer` or `./scriptname/uninstaller`.

You can also place config files, zip files, or anything else you need in
that folder as well. Just make sure to keep the names `installer` and 
`uninstaller` reserved for the actual install/uninstall scripts.

With that said, your script must adhere to various standards to ensure a 
consistent user experience between all of the scripts. Below, we outline 
the major areas that your script must adhere to.

### Language

Scripts can be written in any language that is pre-installed on Koding 
VMs, but a shell language (Fish, Bash, etc) is recommended.  Ensure that
your script has a shebang hash at the top pointing to an environment 
variable, and `kpm` will use that as the run process for the 
script.

*NOTE:* Fish is currently required for scripts, but this requirement will 
be removed in the near future.

### Naming

The name of the script is very important, as the name of the script 
directly correlates to the name of the command. Every script seen in the 
`./foo/installer` format is accessible from `kpm install foo`.

For example, if you named your script `hello-world`, then it could be 
installed with:

```text
kpm install hello-world
```

Likewise, file extensions such as `.fish`, `.bash`, and `.sh` should not 
be used as they would have to be part of the command as well. Such as:

```text
kpm install hello-world.fish
```

This is unneeded, so it should not be used in the name of your script.

### Minimal Configuration

Because these scripts are intended for absolute beginners, we cannot 
prompt for a full range of configuration options. Every prompt should be 
thought about carefully, and used only if required.

Ideally, each script will have no more than two or three prompts.

### Checking Edge Cases

A series of checks should be done at the beginning of every script. Some 
can be substituted where applicable.

- Is this package already installed?
- Is the user logged in as the proper user? *(Ie, not root)*
- Does the user have enough storage space to install the package?
- Does the user have requirements *(mysql, etc)* installed?

If any of your checks fail, the script should exit immediately. It's best 
to exit before any changes to the system are made, whenever possible, so 
that a bad environment is an unchanged environment.

Likewise, if any of your installation steps exit with any sort of 
failure, it is important that the script exits with a meaningful, but 
concise, error message.

Installations should not continue if the environment is not as expected.

### Message Formatting

Where applicable, messages should be copied from existing scripts for a 
consistent user experience.

### Exit Statuses

After each command, you should check for a non-zero exit status. After 
informing the user that something went wrong *(in a beginner friendly 
way!)*, you should exit with the same status that the command exited 
with. This may mean logging the error into a temporary variable, and 
logging it.

Fish Shell Example:

```fish
sudo apt-get install foo
or begin
  set -l err $status
  echo "Error: Failed to install foo"
  exit $err
end
```

In this Fish Shell example, we run the command like normal. After the 
command runs, `or` is triggered if the `$status` is not-zero. `begin` 
starts a codeblock.

In the `begin` codeblock, we store the `$status` into the `err` variable, 
because `echo` will set `$status` back to zero. We then `exit $err`.

### Debug Messages

In kpm, `STDERR` is considered a debug stream. Print errors, or any debug 
information desired. By default, kpm does not display this debug 
information to the user.

If a command fails, as in the exit status example above, we should log a 
beginner-friendly message to the user to inform them of the error. Don't 
bother including detailed information here, save that for the debug 
print. You can print to STDERR *(debug)*, as seen below:

```fish
echo "This is a debug message" >&2
```

The `>&2` syntax forwards the output of `echo` to STDERR. Kpm will then 
record this information depending on user configuration.



[user guide]: http://learn.koding.com/guides/getting-started-kpm
