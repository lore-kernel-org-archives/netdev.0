From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Tue, 18 Jan 2005 15:36:58 +0100
Message-ID: <20050118143658.GA11474@xi.wantstofly.org>
References: <20050117152312.GC26856@postel.suug.ch> <1105976711.1078.1.camel@jzny.localdomain> <20050117160539.GD26856@postel.suug.ch> <1105979807.1078.16.camel@jzny.localdomain> <20050117165626.GE26856@postel.suug.ch> <1106002197.1046.19.camel@jzny.localdomain> <20050118134406.GR26856@postel.suug.ch> <1106058592.1035.95.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        Werner Almesberger <werner@almesberger.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1106058592.1035.95.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2005 at 09:29:52AM -0500, jamal wrote:

> > > Another thing that would be really neat is to have a iso like cli
> > > (something like what zebra has) so you can go down the parse tree to
> > > say the ematch level and just start typing away these commands.
> > > Should probably be easy to rip off the vtysh stuff off zebra or
> > > use libio or something along those lines to do this.
> > 
> > I wouldn't call it easy but it's doable. 
> 
> I dont think its hard at all. It would take me, cycles pending, not more
> than a day to whip something off libio. 

If you do this, please consider using Juniper config syntax instead
of doing it the Cisco/quagga way.


cheers,
Lennert
