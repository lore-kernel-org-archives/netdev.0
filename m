From: Mark Mielke <mark@mark.mielke.cc>
Subject: Re: RFC: per-socket statistics on received/dropped packets
Date: Wed, 12 Jun 2002 01:20:04 -0400
Sender: owner-netdev@oss.sgi.com
Message-ID: <ae6mah$7ck$2@main.gmane.org>
References: <20020609.213440.04716391.davem@redhat.com> <Pine.LNX.3.96.1020611183218.29598A-100000@gatekeeper.tmr.com> <20020611.204119.58650447.davem@redhat.com> <20020611235726.P25193@grendel.conscoop.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, davidsen@tmr.com,
   greearb@candelatech.com, cfriesen@nortelnetworks.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Richard Guy Briggs <rgb@conscoop.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <20020611235726.P25193@grendel.conscoop.ottawa.on.ca>; from rgb@conscoop.ottawa.on.ca on Tue, Jun 11, 2002 at 11:57:26PM -0400
List-Id: netdev.vger.kernel.org

On Tue, Jun 11, 2002 at 11:57:26PM -0400, Richard Guy Briggs wrote:
> On Tue, Jun 11, 2002 at 08:41:19PM -0700, David S. Miller wrote:
> >    From: Bill Davidsen <davidsen@tmr.com>
> >    Date: Tue, 11 Jun 2002 18:41:16 -0400 (EDT)
> >      Actually your arguments sound like you have a solution to your problem
> >    and you want everyone to use it even if it doesn't help them. Have you
> >    some emotional tie to SNMP, like being an author?
> Basically Bill, if you don't like this policy, fork the code.  That is
> one of the strengths (and weaknesses) of open source.  If your tree
> works better and gets wider use, then something about it must be better.
> If not, then maybe it wasn't.  This community works on reputation
> capital (and some diplomacy).

To some degree (i.e. I know it is not intentional), this comes across as
blackmail.

Sorta like "if you want to play ball with me, you play by my rules,
otherwise you can go find your own diamond and your own friends to
play with."

I would still like to see David's logic as to why the approach is bad.

So far it amounts to 1) David doesn't like it, 2) David doesn't see a need
for it, or can see other less adequate methods of approximating the same
effect, and 3) David suspects that it will effect the performance of all
users to provide a limited gain for some applications.

'Reputation capital' is earned. I would like to see it 'earned' in
practice given a real requirement from a real developer on a real
world class application.

Statements such as 'the most important thing I do is say no', don't
convince me that a reputation is deserved. The extreme of this is
that an automaton could say no to everything.

Yes, I might be testing David... is it fair? Well, the requirement was
fair, so how could it not be fair?

I (and Bill) are just asking for some logic to show us where we are
wrong. Linus can pull the "I'm god, and that's that" gig. Fine. How
far does the godhead extend? Who else can pull this gig?

I am waiting in anticipation to be shown the error of my ways using
proper logic and iron clad reasoning... :-)

Cheers,
mark

-- 
mark@mielke.cc/markm@ncf.ca/markm@nortelnetworks.com __________________________
.  .  _  ._  . .   .__    .  . ._. .__ .   . . .__  | Neighbourhood Coder
|\/| |_| |_| |/    |_     |\/|  |  |_  |   |/  |_   | 
|  | | | | \ | \   |__ .  |  | .|. |__ |__ | \ |__  | Ottawa, Ontario, Canada

  One ring to rule them all, one ring to find them, one ring to bring them all
                       and in the darkness bind them...

                           http://mark.mielke.cc/
