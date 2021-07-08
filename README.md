# noupdatethunk

A sandbox for solving  https://www.well-typed.com/blog/2016/09/sharing-conduit/

The ghc-dup directory contains a hacked up version of the ghc-dup library, written by Joachim Breitner
See:

- [repo]( http://git.nomeata.de/?p=darcs-mirror-ghc-dup.git;a=commit;h=b90e942c2a9c7a4d6ce75081550cc4c04e8bce7d)
- [hackage](https://hackage.haskell.org/package/ghc-dup-0.1)
- [paper](https://arxiv.org/abs/1207.2017)

Run `nix-shell` in the root of the project. GHC is ghcHEAD, with head.hackage patches applied to packages.

Current state:

- dup appears to be working
- deepDup is commented out

Output from `cabal run dup-paperstats` (inside nix shell, of course):

Observe the difference between `stats:Original:Shared:time` and `stats:SolveDup:Shared:time`. This shows that we are at least doing something.

``` tex

\makeatletter
\begin{tabular}{lrrrrrrrrrrrr}
 \\
& \multicolumn{2}{c}{no sharing}& \multicolumn{2}{c}{shared tree}& \multicolumn{2}{c}{add. thunk}& \multicolumn{2}{c}{partly eval'ed}& \multicolumn{2}{c}{fully eval'ed}& \multicolumn{2}{c}{run twice} \\
& MB & sec.& MB & sec.& MB & sec.& MB & sec.& MB & sec.& MB & sec. \\ \midrule 
original%
&
 {\def\@currentlabel{0}\label{stats:Original:Unshared:mem}0} &
 {\def\@currentlabel{1.23}\label{stats:Original:Unshared:time}1.23}&
 {\def\@currentlabel{800}\label{stats:Original:Shared:mem}800} &
 {\def\@currentlabel{16.95}\label{stats:Original:Shared:time}16.95}&
 {\def\@currentlabel{800}\label{stats:Original:SharedThunk:mem}800} &
 {\def\@currentlabel{16.74}\label{stats:Original:SharedThunk:time}16.74}&
 {\def\@currentlabel{800}\label{stats:Original:SharedEvaled:mem}800} &
 {\def\@currentlabel{16.59}\label{stats:Original:SharedEvaled:time}16.59}&
 {\def\@currentlabel{800}\label{stats:Original:SharedFull:mem}800} &
 {\def\@currentlabel{23.53}\label{stats:Original:SharedFull:time}23.53}&
 {\def\@currentlabel{800}\label{stats:Original:RunTwice:mem}800} &
 {\def\@currentlabel{23.67}\label{stats:Original:RunTwice:time}23.67} \\
\textsf{solveDup}%
&
 {\def\@currentlabel{0}\label{stats:SolveDup:Unshared:mem}0} &
 {\def\@currentlabel{1.23}\label{stats:SolveDup:Unshared:time}1.23}&
 {\def\@currentlabel{0}\label{stats:SolveDup:Shared:mem}0} &
 {\def\@currentlabel{1.21}\label{stats:SolveDup:Shared:time}1.21}&
 {\def\@currentlabel{800}\label{stats:SolveDup:SharedThunk:mem}800} &
 {\def\@currentlabel{16.82}\label{stats:SolveDup:SharedThunk:time}16.82}&
 {\def\@currentlabel{800}\label{stats:SolveDup:SharedEvaled:mem}800} &
 {\def\@currentlabel{16.95}\label{stats:SolveDup:SharedEvaled:time}16.95}&
 {\def\@currentlabel{800}\label{stats:SolveDup:SharedFull:mem}800} &
 {\def\@currentlabel{24.09}\label{stats:SolveDup:SharedFull:time}24.09}&
 {\def\@currentlabel{0}\label{stats:SolveDup:RunTwice:mem}0} &
 {\def\@currentlabel{2.47}\label{stats:SolveDup:RunTwice:time}2.47} \\
\textsf{rateDup}%
&
 {\def\@currentlabel{0}\label{stats:RateDup:Unshared:mem}0} &
 {\def\@currentlabel{1.42}\label{stats:RateDup:Unshared:time}1.42}&
 {\def\@currentlabel{2}\label{stats:RateDup:Shared:mem}2} &
 {\def\@currentlabel{1.46}\label{stats:RateDup:Shared:time}1.46}&
 {\def\@currentlabel{2}\label{stats:RateDup:SharedThunk:mem}2} &
 {\def\@currentlabel{1.46}\label{stats:RateDup:SharedThunk:time}1.46}&
 {\def\@currentlabel{2}\label{stats:RateDup:SharedEvaled:mem}2} &
 {\def\@currentlabel{1.44}\label{stats:RateDup:SharedEvaled:time}1.44}&
 {\def\@currentlabel{800}\label{stats:RateDup:SharedFull:mem}800} &
 {\def\@currentlabel{24.89}\label{stats:RateDup:SharedFull:time}24.89}&
 {\def\@currentlabel{800}\label{stats:RateDup:RunTwice:mem}800} &
 {\def\@currentlabel{18.82}\label{stats:RateDup:RunTwice:time}18.82} \\
unit lifting%
&
 {\def\@currentlabel{0}\label{stats:Unit:Unshared:mem}0} &
 {\def\@currentlabel{1.45}\label{stats:Unit:Unshared:time}1.45}&
 {\def\@currentlabel{0}\label{stats:Unit:Shared:mem}0} &
 {\def\@currentlabel{1.42}\label{stats:Unit:Shared:time}1.42}&
 {\def\@currentlabel{0}\label{stats:Unit:SharedThunk:mem}0} &
 {\def\@currentlabel{1.41}\label{stats:Unit:SharedThunk:time}1.41}&
&
&
&
&
 {\def\@currentlabel{0}\label{stats:Unit:RunTwice:mem}0} &
 {\def\@currentlabel{2.85}\label{stats:Unit:RunTwice:time}2.85} \\
church encoding%
&
 {\def\@currentlabel{0}\label{stats:Church:Unshared:mem}0} &
 {\def\@currentlabel{2.03}\label{stats:Church:Unshared:time}2.03}&
 {\def\@currentlabel{0}\label{stats:Church:Shared:mem}0} &
 {\def\@currentlabel{2.02}\label{stats:Church:Shared:time}2.02}&
 {\def\@currentlabel{0}\label{stats:Church:SharedThunk:mem}0} &
 {\def\@currentlabel{1.99}\label{stats:Church:SharedThunk:time}1.99}&
&
&
&
&
 {\def\@currentlabel{0}\label{stats:Church:RunTwice:mem}0} &
 {\def\@currentlabel{3.96}\label{stats:Church:RunTwice:time}3.96} \\
\end{tabular}
\makeatother

```
Output from `cabal run dup-bits`:
