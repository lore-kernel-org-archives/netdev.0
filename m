From: Horst von Brand <vonbrand@inf.utfsm.cl>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 13:00:25 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae7uv9$jsb$2@main.gmane.org>
References: <mark@mark.mielke.cc>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Mark Mielke <mark@mark.mielke.cc>
In-Reply-To: Message from Mark Mielke <mark@mark.mielke.cc>
   of "Wed, 12 Jun 2002 10:53:55 -0400." <20020612105355.A20760@mark.mielke.cc>
List-Id: netdev.vger.kernel.org

[CC:'s chopped down to the lists]

Mark Mielke <mark@mark.mielke.cc>
> On Wed, Jun 12, 2002 at 09:00:08AM -0400, jamal wrote:
> > On Wed, 12 Jun 2002, Lincoln Dale wrote:
> > > At 08:33 AM 12/06/2002 -0400, jamal wrote:
> > > >If 3 people need it, then i would like to ask we add lawn mower
> > > >support that my relatives have been asking for the last 5 years.
> > > lawn-mower support sounds like a userspace application to me.
> > But we need a new system call support
> 
> This is another non-argument not dissimilar to the method of arguing that
> David has used up to this point.
> 
> If lawn-mower support (whatever that is) is something that people
> would use, then perhaps it *should* be added, even if it needs a new
> system call. You have not shown a valid argument against your own
> sarcastic suggestion, other than an implicit sneer.

Linux development has _always_ worked by:

1) You have a problem
2) You come up with a solution
3) Others use your patch, perhaps refine it
4) A discussion ensues on the worthyness of the patch
5) The community (or at least the halfgods in charge of keeping the Holy
   Source ;-) sees that the patch is worthwile, tested, and has enough
   users
6) After some further cleanups and fixes the patch is accepted into the
   kernel
7) The code is carried as part of the standard kernel, and updated with it

Being halfway through (2) or going on (3) and whining that _others_ do the
work to take care of finishing implementing a solution and then maintaining
it for you (jumping to (7)) won't get you anywehere. Guaranteed.

Perhaps your proposed solution is subobtimal.

Perhaps your problem is so outlandish that a solution has no place in the
standard kernel.

Perhaps solving the problem, even a common one, isn't worth the effort in
placing a solution in the kernel, and then maintaining it forever.
-- 
Dr. Horst H. von Brand                   User #22616 counter.li.org
Departamento de Informatica                     Fono: +56 32 654431
Universidad Tecnica Federico Santa Maria              +56 32 654239
Casilla 110-V, Valparaiso, Chile                Fax:  +56 32 797513
