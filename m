From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Sat, 16 Aug 2003 18:36:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817013624.GB2173@bougret.hpl.hp.com>
References: <20030815154608.56cf0551.shemminger@osdl.org> <20030815230546.GA31831@bougret.hpl.hp.com> <20030816052048.5858d68a.davem@redhat.com> <20030817001405.GA1916@bougret.hpl.hp.com> <20030816175851.58a2c179.davem@redhat.com> <20030817011131.GA2120@bougret.hpl.hp.com> <20030816180946.228b5909.davem@redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
   lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030816180946.228b5909.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 16, 2003 at 06:09:46PM -0700, David S. Miller wrote:
> On Sat, 16 Aug 2003 18:11:31 -0700
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 
> > Would it be possible for Stephen to use some real IrDA hardware so
> > that he can double check what he is doing ?
> 
> And alternatively, what?  We let known bugs sit in the tree
> because of IRDA?

	Wow ! I did not mean to argue and stop the work, if you
understood that, I'm sorry for the misunderstanding.
	I'm just trying to understand the reason for it, how best to
proceed, and that's why I took the time to give Stephen some
constructive suggestions (as well as my worries). I'm just doing my
job, and I don't think I'm unnegociable.

> We've had to edit and hack on lots of obscure ISA ethernet drivers to
> do this so far that probably nobody has tried to use in years and very
> few people have access to.  Not just trivial changes, we've had to
> rewrite some of their probe routines in some cases.

	It's fairly easy to get hold of some IrDA hardware, and in the
worse case you can use a serial crossover cable to test it. It's not
like I'm asking the impossible.

> The work simply must be done.

	After your explanation, I didn't argue with that. But let's do
quality work, not a quick job.

> If we add bugs, the first person who tries to use it will find out
> and report the problem.

	If the bug report come in one year, nobody will remember the
context of the work. It's better to get it right the first time, and
that's what I'm trying to acheive.

	Have fun...

	Jean
