From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: [PATCH] (1/5) get rid of useless hashbin in irtty
Date: Sat, 16 Aug 2003 17:14:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817001405.GA1916@bougret.hpl.hp.com>
References: <20030815154608.56cf0551.shemminger@osdl.org> <20030815230546.GA31831@bougret.hpl.hp.com> <20030816052048.5858d68a.davem@redhat.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, irda-users@lists.sourceforge.net, netdev@oss.sgi.com,
   lists@mdiehl.de
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030816052048.5858d68a.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 16, 2003 at 05:20:48AM -0700, David S. Miller wrote:
> On Fri, 15 Aug 2003 16:05:46 -0700
> Jean Tourrilhes <jt@bougret.hpl.hp.com> wrote:
> 
> > On Fri, Aug 15, 2003 at 03:46:08PM -0700, Stephen Hemminger wrote:
> > >
> > > Working on converting IRDA to new netdevice semantics,
> > 
> > 	I hope you realised that this is most likely 2.7.X
> > material.
> 
> Without moving to the new netdevice semantics, you're
> drivers will be broken.
> 
> This isn't a happy cleanup change, it is necessary.

	Curently driver do work properly (including SMP). Does it mean
that you plan to have big changes before 2.6.0 is released ?
	Regards,

	Jean
