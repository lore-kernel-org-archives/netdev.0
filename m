From: Ralph Doncaster <ralph@istop.com>
Subject: RE: Route cache performance under stress
Date: Tue, 10 Jun 2003 10:03:33 -0400 (EDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.LNX.4.51.0306100941480.26498@ns.istop.com>
References: <008001c32eda$56760830$4a00000a@badass> <20030609195652.E35696@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092006420.12038@ns.istop.com> <20030609204257.L35799@shell.cyberus.ca>
 <Pine.LNX.4.51.0306092200150.28167@ns.istop.com> <20030610061010.Y36963@shell.cyberus.ca>
 <Pine.LNX.4.51.0306100828220.26498@ns.istop.com> <20030610091736.V37313@shell.cyberus.ca>
Reply-To: ralph+d@istop.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: CIT/Paul <xerox@foonet.net>, 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jamal Hadi <hadi@shell.cyberus.ca>
In-Reply-To: <20030610091736.V37313@shell.cyberus.ca>
List-Id: netdev.vger.kernel.org

On Tue, 10 Jun 2003, Jamal Hadi wrote:

> > No, it needs to work in the worst case.  If some script kiddie can peg my
> > CPU with a synflood then there's still a problem.
> >
>
> Lets work on defining "real world". Factor in the script kiddie.

"real world" is the worst-case DOS tool available.  Synflood tools like
juno seem to fit that category.  If you think juno is not a good
real-world test, then keep pissing people off and you'll find out how real
it is. ;-)

> > > I have spent many hours investigating peoples problems sshing to their
> > > machines only to find out they didnt follow instructions. After the
> > > 10th person doing the same thing, what do you expect my reaction to be?
> >
> > Take 15 minutes and write a web page with the magic settings required to
> > make things work.
> >
>
> I have many times. I still do. It is also a thankless task.

URL?  I've looked at almost everything on your web page since you were
involved in the pppoe client software.  I haven't seen anything that says
how to sprinkle the pixie dust so my router works well.

> > No, as I said I'm moving ~30mbps and ~10kpps in and out of 2 3c905cx
> > cards.
> >
>
> Change your NICs. I dont know what else to suggest.

Yup.  It just takes a bit of time and planning when the box is deployed in
a POP 400km away...

> > The last time I looked at the zebra list things seemed pretty dead.  Most
> > of the new work is now happening on the commercial zebra development.
> >
>
> Maybe its time to fork Zebra into something that has the same momentum it
> had in the earlier days.

Hmmm... maybe we can both bug MCR to try your suggested changes...

> > You don't seem to get it.  There's at least a dozen things more important
> > to me than seeing Linux routing performance compete with Cisco and BSD.
>
> Again, if you wanna complain about it at the level you are i think its
> only fair you help. I actually dont care about CISCO or BSD. We dont win
> because someone else looses. We simply want to be the best.

You can want to be the best, but I don't think it's fair to sucker people
into using Linux as a core router with false claims.

> > Now that people like Rob and Dave are taking a hard look at it I think
> > it's worth my while to ante up for a couple more rounds.  I still fell
> > like a sucker that should have walked away from the table a long time ago
> > though.
> >
>
> I think your setup maybe the question. Like i said theres probably a
> hunderd variables involved. It is up to you to isolate things.
> Yes, theres a support line in open source, but it is rewarded more
> when people show some effort.

Fuck, if you think I haven't put any effort into it already then there's
no point in even trying any more.

> to be comfortable with what they know best. Most of the people i have
> met that put Linux down or consider it a joke come from the old
> BSD camp. Its their loss and i dismiss anything they have to say.

In my case I would have been better off to dismiss your advice a year ago.
How does that help the Linux cause?

-Ralph

