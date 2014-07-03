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

**&lt;rant&gt;**

> ### Mice Cannot Write Code
>
> Creating new and interesting functionality &endash; in effect, **solving
> problems** with software &endash; is all about issuing commands for the
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
> You need to know how to open, read and edit text files in a text editor (any
> of the myriad of options available will do, including Notepad if you have
> nothing better available). You will also need to know how to navigate a
> directory (tree) structure, issue commands from and otherwise perform basic
> tasks at a **command prompt**. If you are the type of person who asks "what
> program do I use to open this?" at the first encounter of an unfamiliar file
> type before seeing for yourself what type of data that file contains, then
> perhaps "Blood Donor" would be a more suitable career choice. 

**&lt;/rant&gt;**

Inspired By
-----------

I was looking for a way to get
[Git](http://en.wikipedia.org/wiki/Git_%28software%29) on my workstation
without violating my company's software installation policies, and without
having to wait the months -- nay, years, based on previous experience --
that it usually takes to get software certified through official channels.

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
7 with network access (net-nannies and blocked sites notwithstanding) running
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
