Developing Web Applications on Windows as a Normal User
=======================================================

Setting up a MEAN development environment on Windows 7 SP1 (OOBE) as a
non-admin (normal) user.

Assumptions
-----------

1.  You have a Windows 7 SP1 workstation. (I don't think the 'flavor' matters,
    although this has only been tested on Windows 7 Enterprise with Service
    Pack 1.)
2.  You do **not** have administrative privileges on your workstation. In
    other words, you have a normal user account, and can only write files to
    your home directory, your own user profile, and perhaps a few 'shared'
    (public) directories.
3.  You cannot 'install' software (meaning write to any of the shared
    `Program Files`, `Program Files (x86)`, or `Windows` directories or any
    shared registry locations).
4.  You cannot count on any other software or system updates to have been
    installed or, if they have been installed, you cannot count on any
    software or system updates to have been installed and/or configured
    correctly.<br/><br/>

    ...finally, and most importantly...<br/><br/> 

5.  **You need to get some work done.**

Usage
-----

This is currently in an "alpha" state, but basic usage is as follows:

Use the [Download
Zip](https://github.com/MShawnDillon/webdev-win/archive/master.zip) button on
GitHub (should be on the right if you're reading this on [GitHub]) to download
the current contents of this entire repository (but not the repo itself) as a
compressed archive.

Since Windows marks files you download from the Internet as "blocked"
(untrusted) by default (an annoyance that provides no security benefit
whatsoever), you'll need to first right-click on the ZIP file to open the
context menu, then choose "Properties", and on the dialog that pops up, click
on the "Unblock" button.

With that out of the way, extract the contents somewhere (anywhere, really).

Open a Command Prompt and navigate to the directory where you placed these
files.

Type: `get-to-work`

### What Happens When I Type `get-to-work`?

Well, read the source, if you're really curious. :-) Here is the TL;DR version,
which is still pretty long.

The batch file launches the `get-to-work.ps1` PowerShell script.

The PowerShell script then pulls in all of the other scripts it needs to work.

It then sets about trying to automatically determine who you are (reading from
environment variables, mostly), but specifically it needs to know your display
name (at least, the display name as it is stored either in Active Directory or
on your machine), as well as your e-mail address. If it cannot determine this
information automatically, it may ask you for it.

These two pieces of information (display name and e-mail address) are needed
to correctly configure Git and other tools.

Next, it finds out whether you have Git already, and if not, it gets a
portable version that can be used without installation (for example, you could
put Portable Git on a USB stick and carry it around with you; at least, that
is the idea under which it was developed). What you **won't** get with the
portable version of Git is the Windows Shell Extension (`git-cheetah`) that
provides the 'Git GUI Here' and 'Git Bash Here' commands, since that feature
requires changes to system-wide registry keys.

Git is ultimately a command-line tool in any case, so a couple of missing
context menu items are not likely to cause a lot of pain and suffering.

By default, the `get-to-work.ps1` script puts Git into your `%APPDATA%`
directory, so as to keep it out of your way, but still make it available to
your own user account.

When the script is sure that Git is available, it then sets the 'user.name',
'user.email', 'push.default', 'alias.serve', and 'alias.hub' Git global
configuration settings. These settings are stored in the .gitconfig file in
your user profile (e.g., `C:\Users\Some User\.gitconfig`). Global
configuration, in Git terms, means outside of any particular repository. These
settings apply to all of the repositories that you use or create by default,
but they can also be overridden within any given repository.

The purpose of the 'user.name' and 'user.email' settings should be pretty
obvious. When you commit changes, this is "who" those changes in the
repository will be associated with. Notice that you can impersonate someone
else if you really wanted to, simply by providing a false name and email
address for these settings. If you're wondering whether or not this
constitutes a security issue, the short answer is "no". Any name and e-mail
address can be tacked onto a set of changes on your own copy of the repo.
It is the process of authenticating yourself when you go pushing those changes
up to a server that makes this a non-issue. Every pack of changes knows where
it came from and who posted the whole pack (comprising multiple commits), and
who posted the pack has little to do with the name associated with individual
commits. In short (too late), security is implemented when you share your
changes, not when you make them. (In other words, any changes that you don't
share ultimately don't exist except in your own little world.)

The 'push.default' setting is set to 'simple' to match a new default setting
that has yet to be introduced, and prevents spurious [warning
messages][GitPushDefaultWarning] that advertise this upcoming change.

The 'alias.serve' and 'alias.hub' settings are new (to me, at least). Git
never ceases to surprise and amaze me. Like the original poster of [this
question][GitServe], I missed Mercurial's simple built-in web server for quick
collaboration directly between peers in a LAN environment. These aliases allow
you to quickly (and temporarily) host any repository on your own box and share
it directly with other people on your network. Within the root of any given
repository, typing `git serve` will host that repository for other users to
pull from (the pulling user would use something like
`git clone git://machinename/` to clone the repository directly from your
`machinename`). Similarly, `git hub` (note the space...this is the command,
not the company of the same name) allows other users to not only read your
repository, but also to push their own changes to you. This is distributed
version control at its finest; notice that no centralized server needs to be
involved (though you will likely want to use one when you share changes with
your company-at-large).

**&lt;rant&gt;**

> ### Mice Cannot Write Code
>
> Creating new and interesting functionality &#8211; in effect, **solving
> problems** with software &#8211; is all about issuing commands for the
> machine to carry out on your behalf. At times, those commands may be stored
> in an intermediate format waiting to be transformed into machine code so
> that the machine can interpret your instructions more rapidly; at other
> times this involves configuring or selecting a set of options for another
> program written by someone else that already has the functionality you need
> just waiting to be tapped and put into service for your own use. Far more
> often though, this involves simply *telling the computer what to do* and
> finding out what it is capable of, discovering how the tools and
> technologies you use actually function, simply by *issuing commands*.
>
> It is hard to do this when the programs that most users are familiar with
> are specifically designed to *limit what you can accomplish* to the features
> offered and supported by the program in question. Maybe that program doesn't
> have the capability you need, or maybe it does, but doesn't execute it the
> way you want it to or provide the hooks necessary for you to customize what
> it does and how it does it. Working around the idiosyncrasies of a program
> is often a full-time job in itself.
>
> Fortunately, there is a program that is *purpose-built* to sit there and
> wait for you to command it; to tell it exactly what you want it to do; and
> whose only limitation is what the machine and, by extension, the set of
> machines and programs and people and things that you can access from it, is
> capable of.
>
> You need to know how to open, read and edit text files in a text editor (any
> of the myriad of options available will do, including Notepad if you have
> nothing better available). You will also need to know how to navigate a
> directory (tree) structure, issue commands from and otherwise perform basic
> tasks at a **command prompt**. If you are the type of person who asks "what
> program do I use to open this?" when you first encounter an unfamiliar file
> type, before seeing for yourself what type of data that file contains, then
> perhaps **Blood Donor** would be a more suitable career choice. 

**&lt;/rant&gt;**

Inspired By
-----------

I was looking for a way to get
[Git](http://en.wikipedia.org/wiki/Git_%28software%29) on my workstation
without violating my company's software installation policies, and without
having to wait the months &#8211; nay, years, based on previous experience
&#8211; that it usually takes to get software certified through official
channels.

I ran across [this][NonAdmin_Git], and had also been using the excellent
[nvm][NVM] on personal development machines to manage and use multiple
versions of [Node][NodeJS] without requiring `sudo` privileges to install
[NPM][NPM] packages globally. I was also aware of the existence of the
[Node Version Manager for Windows][NVMW] that accomplished a similar goal.

Note that the word 'globally' as used above is a bit of a misnomer; it means
that these packages are downloaded to a location in your own user profile
and made available for use outside the context of any specific application or
library. This makes globally installed packages ideal for things like
command-line tools that should be available *to your own user account* from
any command prompt or terminal window.

Also note that *installing* a package refers to the act of downloading it to
a location on your own machine. Using this definition, you are technically
'installing' the HTML, stylesheets, images, scripts, and other resources from
every web page you happen to visit. Most package managers, including
Microsoft's [NuGet][NuGet] package manager and the [Node Package Manager][NPM]
use this definition when they refer to installing a package; rather than the
older, more traditional definition that typically involved making system-wide
changes to your machine.

In any case, I wanted to create a script that would basically 'start from
scratch', assuming only a locked-down out-of-the-box installation of Windows
7 with network access ('net nannies and blocked sites notwithstanding) running
in an almost-draconian corporate environment, and from that point get a
complete Git + Node + NPM + MongoDB development environment running, and
running well, able to easily support rapid development and accelerate even the
most time-sensitive development tasks -- all as a normal, ordinary user with
no special privileges whatsoever.

[NonAdmin_Git]: http://davidpp.com/git-on-windows-with-no-admin-rights-in-3-steps/ "Git on Windows with no admin rights in 3 steps."
[NVM]: https://github.com/creationix/nvm "Node Version Manager"
[NVMW]: https://github.com/hakobera/nvmw "Node Version Manager for Windows"
[NodeJS]: http://nodejs.org/ "NodeJS"
[NPM]: https://www.npmjs.org/ "Node Packaged Modules"
[NuGet]: https://www.nuget.org/ "NuGet Gallery"
[NPMConfig]: https://www.npmjs.org/doc/misc/npm-config.html "NPM Configuration Settings"
[GitHub]: https://github.com/ "GitHub"
[GitPushDefaultWarning]: http://stackoverflow.com/questions/13148066/warning-push-default-is-unset-its-implicit-value-is-changing-in-git-2-0
[GitServe]: http://stackoverflow.com/questions/377213/git-serve-i-would-like-it-that-simple
