# JEDI Code Format

The following Sourceforge pages are available:

* [Download Executables and Source Code](https://sourceforge.net/project/showfiles.php?group_id=41564)
* [Change log](Jcf2changes.html)
* [Bug reporting and tracking](http://sourceforge.net/tracker/?group_id=41564&atid=430780)
* [Feature request](https://sourceforge.net/tracker/?atid=430783&group_id=41564&func=browse)
* [Support request](https://sourceforge.net/tracker/?atid=430781&group_id=41564&func=browse)
* [Forums](https://sourceforge.net/forum/?group_id=41564)
* [Project statistics](https://sourceforge.net/project/stats/?group_id=41564&ugn=jedicodeformat)
* The subversion repository is at [http://jedicodeformat.svn.sourceforge.net/svnroot/jedicodeformat/trunk/CodeFormat/Jcf2/](https://jedicodeformat.svn.sourceforge.net/svnroot/jedicodeformat/trunk/CodeFormat/Jcf2/)
* And other functions via the [project details page](https://sourceforge.net/projects/jedicodeformat/)


## What does it do?

The formatter can standardise all aspects of Delphi Object Pascal source code formatting, including indentation, spacing and capitalisation. If you are still not sure, see [the examples of program input and output](examples.html) . It works on Delphi and Delphi.NET syntax.

## Why use a code formatter?

It is useful if you are taking over code and don't like the original formatting. It is useful if you are trying to bring code from multiple sources to one standard.

A human **can** always produce better formatting than a program, but in many cases they don't. If you find a piece of code's formatting annoying or hard to read, this program can save you a lot of time.

On your own code it can catch your mistakes, and even automate some mundane tasks that may have annoyed you but you haven't bothered with up to now (e.g. to turn tabs to spaces, standardise  indentation, spacing and capitalisation, globally change a variable or procedure name, globally remove redundant unit from all uses clauses, or even to insert the MPL licence comment into all units).

## How should I format my Delphi programs?

You should format your Delphi programs as per this program's default settings, i.e. [as Borland suggests](http://dn.codegear.com/article/10280).

## Licence and disclaimer:

This program is free and open-source.

As of version 2.37, JCF is available under a dual licence -  [Mozilla Public Licence (MPL)](http://www.mozilla.org/MPL/MPL-1.1.html) 1.1, or [GPL](http://www.gnu.org/licenses/gpl.html) 2.0 or later.

The original licence was the MPL - I chose the MPL particular open-source license at the [suggestion](http://www.delphi-jedi.org/Jedi:ADMINLICENSING:187710526) of the [Delphi-JEDI group](http://www.delphi-jedi.org/). the GPL was added at the request of members of the [Lararus project](http://www.lazarus.freepascal.org/), who use this licence, and would like to link in JCF code.

If you improve this program in any way (bug fix, new feature, better algorithm, whatever), I would appreciate it if you send those improvements back to me for possible inclusion in a future version.

**Disclaimer:** This program may have bugs or not yet fully meet it's design objectives. Although it has been fairly well tested and is used with some success, I cannot make any guarantees. If you care about the quality of this program, send in bug reports.

I recommend using a [source control system](http://www.mactech.com/articles/mactech/Vol.14/14.06/VersionControlAndTheDeveloper/) such as [Subversion](http://subversion.tigris.org/),  [Microsoft TFS](http://msdn2.microsoft.com/en-us/teamsystem/), [CVS](http://www.nongnu.org/cvs/), [TeamSource](http://community.borland.com/article/1,1410,10492,00.html) or the like. Remember "[Source control is like flossing](http://community.borland.com/article/1,1410,10492,00.html) - you don't have to floss **all** your teeth - just the ones you want to keep." If you are still not using such a tool, **please make backups** before using the formatter.

## How to install

This version is downloadable as source or as executable.

Install the executables as follows:

* [Download the executable programs](https://sourceforge.net/project/showfiles.php?group_id=41564), and unzip to a suitable directory.
* Place the file `JCF2Settings.cfg` in your windows directory.
* Run the gui `JcfNotepad.exe` to experiment with files.
* Run the GUI program `JcfGui.exe` to format files from the gui - this is good when you have a directory or directory tree of Delphi files that you want to format.
* Run the commandline program `jcf.exe` if you are making a batch file or you are masochistic.
* Use the IDE plugin to format files or projects while you are working in the Delphi IDE.

The Delphi IDE pluggin can be installed for Delphi 7 as follows. All packages can be installed by selecting the menu item `Component|Install packages` and clicking the "Add" button.

* Install the [JCL design-time package](https://www.delphi-jedi.org/) into Delphi.
* Install the JVCL design-time controls into Delphi.
* Install the JcfIde7.bpl
* Read the [Instructions for use](idepluggin.html) for the JCF IDE plugin.

Install the source as follows:

* [Get the JCL code library](http://homepages.borland.com/jedi/jcl/), install the design-time packages.
* Download, build and install the [JVCL components](http://homepages.borland.com/jedi/jvcl/).
* For the test harness, you will also need [DUnit](http://dunit.sourceforge.net/).
* [Download the source](https://sourceforge.net/project/showfiles.php?group_id=41564), and unzip to a suitable directory.
* Launch Delphi.
* Open the code formatter program group in `JediCodeFormat.bpg`
* Compile and run. Take care, have fun.

Things that can go wrong with compilation:

* The project TestProject.dpr is opened by default, and this project is full of warnings. Remember it is just test code for the formatter to work on, and is not intended to be run. Delphi opens the last project in a group automatically, and I wish Borland would change this. TestProject is the least important of the projects. Use the menu item `View|Project manager` and open the first project, JediCodeFormat.dpr instead.
* Some files can't be found (you will get an error like "`[Fatal Error] JediCodeFormat.dpr(142): File not found: 'JclStrings.dcu'."` The JCF files and JediComponents files are not included in this zip file. You may have placed them  in a different location on your hard drive. Change the paths in the `JediCodeFormat.dpr, Jcf.dpr and Jcfide.dpk` files.
* The files are marked read-only. This is the way that they come out of the source-control system. You may clear this setting.
* The `Output` directory is not found. I like to configure Delphi to write the `.dcu` files and executables to an output directory. Naturally, when distributing the source, this directory is empty. WinZip doesn't store empty directories, so it may not exist after you unzip. Sometimes I remember to put a dummy file called Delme.tmp in this directory. If you see that file, it has already served it's purpose and may be removed.  Make an `Output` directory under your CodeFormat directory, or clear (or change) this setting in Delphi's `Project|Options|Directories/Conditionals` settings.
* `Jdfide.dpk` gives a lot of warnings about implicitly imported units. Yes it does. It's not serious.
* All projects except the first will not build at all because of files that are not found, and these files are part of JCF. Make sure that you have an output directory, and that it contains the DCU files, and that it is on the project's search path.
* When compiling all projects, do a "Build all" not a "Compile all", as there is a little bit of code behind  $IFDEF macros to make the IDE plugin different to the GUI executable. Compiling without rebuilding is not sensitive to the fact that these units need to be recompiled due to changed project defines.

## How do I report a bug?

[Report the bug here](http://sourceforge.net/tracker/?group_id=41564&atid=430780). Submit a test case and (optionally) a fix to the source, and tell me which if these categories, ordered by severity, that you think the bug falls into:

1.  Program error: The program crashes (access violation, assertion failure, etc.) or aborts when given your test case.
2.  Bad output: The program gives output that does not compile when given your test case.
3.  Lousy formatting: The output compiles but looks bad. Give an example of input code that is badly formatted, and preferably a fix.
4.  Non-standard formatting: The output is readable but not compliant with the agreed standards. Give an example with your test case of what you think the output should be, and preferably a fix.
5.  Missing option: The formatting that you want is not standard, but it's how you do it and the formatter does not support it. If you don't give a fix that adds your favourite option, give an example with your test case of what you think the output should be.

## What to do if you don't like this program

Breath. Calm down. Remember that I am offering this program free and without any guarantees. Remember that I did not force you to use it. Remember that I strongly suggested that you make backups. Constructive suggestions, especially those with code, will be kindly treated. Flames will be deleted. I haven't had any flames yet for this program, and I'd like to keep it that way.

## Where is the program going?

This program is mostly in maintenance mode now - I fix bugs, track changes in Delphi versions and language syntax, and release an update every month or two.

The goal for Version 2.0 is that the program should have no bugs and generate output compliant with official code formatting standards (and have options for other styles). It should allow the user to configure anything that needs to be configured, and it should not overload the user with useless options.

It should also have, in order of priority: readable source, an easily extendable and well-documented architecture, and should run fast enough.

## Can I get involved?

Yes, please do. Report a bug. Request a feature. Download the source, compile it, and fix a bug or add a feature. If your addition is sound it will be included in the next release and your name will be listed. If you want to be added to the Sourceforge project developers list, do this first, then we'll talk. I'm not interested in adding people the project's developers list just because they want the status of being there. I **am** interested in giving that status to people who have proved that they can and do add something of value. I am a bit sceptical of wild verbal enthusiasms. To paraphrase Bruce Sterling, it doesn't take youthful enthusiasm, it takes dogged middle-aged persistence.

However bear in mind that this is open source software. If you want to play with the code, forge ahead in your own direction or just or roll your own version of JCF, go right ahead.

## What other Delphi code formatters exist?

*   [Pascal indent](http://pasind.tsx.org/) is a Pascal and Delphi formatter written (in C) by Ladislav Sobr. It can also generate HTML or TeX output from P`ascal or Delphi source.
*   The [Free Pascal](http://www.freepascal.org/) Compiler is available under the [GPL](http://www.gnu.org/) licence, and includes an Object-Pascal code formatter called PTOP.
*   [DelForExp](http://www.dow.wau.nl/aew/DelForExp.html) is a free (but no source) Delphi source formatter by Egbert van Nes
*   The [Source Normalizer](http://www.delphicity.net/catalogue/tools/codeformatters/sourcenormalizer/index.html) costs $47\. I know nothing about it except what is on the web pages
*   [CocolCloak](http://www.cocolsoft.com.au/cocolcloak/cocolcloak.htm) is a rather misguided program that can only obfuscate delphi source code. When version 1 is released, it will cost $150.  It is "a new way of securing your products and source code from theft and reverse engineering". I prefer to [MPL](http://www.mozilla.org/MPL/MPL-1.1.html) the source. The FAQ seems to imply that it will even obfuscate variable names. What a senseless waste of effort.
*   [SourceCoder](http://www.preview.org/cgi-bin/nav_e.pl?t=scshot12.htm) is an extensive source code tool that does code formatting as one of its functions. It costs $89, but there is a free trial version that works for 50 days.

## What other Delphi code tools exist?

You could look for Delphi code tools at [The inner circle project](http://www.innercircleproject.org/).
You could look for the API translations, code library and components at [The Joint Endeavour of Delphi Innovators (project JEDI)](http://www.delphi-jedi.org).
[GExperts](http://www.gexperts.org/)  is Open source programming tools for Delphi and C++ builder. Not only are they good tools, the source is good examples on how to do this kind of thing.
There are several sites that act as clearing-houses for Delphi shareware, components and free code.

## Does JCF just work on Delphi code?

Yes, it is designed with only Delphi in mind. However it may work on other dialects of Pascal. I have no way to test this as I only use Delphi, but if you have any luck, let me know. If you would like JCF to support a syntax element from another dialect of Pascal, then send me a code sample please!

For other languages such as C, Java and so on - do a search on the web and you will probably find a selection of tools.

Contact me via the [forums](http://sourceforge.net/forum/?group_id=41564)
