From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Subject: Re: [PATCH v5 net-next] net: phy: Add Edge-rate driver for Microsemi
 PHYs.
Date: Tue, 4 Oct 2016 15:33:45 +0530
Message-ID: <20161004100344.GA31709@microsemi.com>
References: <1475479393-24308-1-git-send-email-Raju.Lakkaraju@microsemi.com>
 <20161004.004859.1105270097322633239.davem@davemloft.net>
 <20161004065401.GA6097@lunn.ch>
Reply-To: <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        <Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
To: Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20161004065401.GA6097-g2DYL2Zd6BY@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Thank you for comments. I will fix and send the patch.

Thanks,
Raju.

On Tue, Oct 04, 2016 at 08:54:01AM +0200, Andrew Lunn wrote:
> EXTERNAL EMAIL
> 
> 
> On Tue, Oct 04, 2016 at 12:48:59AM -0400, David Miller wrote:
> > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> > Date: Mon, 3 Oct 2016 12:53:13 +0530
> >
> > > From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> > >
> > > Edge-rate:
> > > As system and networking speeds increase, a signal's output transition,
> > > also know as the edge rate or slew rate (V/ns), takes on greater importance
> > > because high-speed signals come with a price. That price is an assortment of
> > > interference problems like ringing on the line, signal overshoot and
> > > undershoot, extended signal settling times, crosstalk noise, transmission
> > > line reflections, false signal detection by the receiving device and
> > > electromagnetic interference (EMI) -- all of which can negate the potential
> > > gains designers are seeking when they try to increase system speeds through
> > > the use of higher performance logic devices. The fact is, faster signaling
> > > edge rates can cause a higher level of electrical noise or other type of
> > > interference that can actually lead to slower line speeds and lower maximum
> > > system frequencies. This parameter allow the board designers to change the
> > > driving strange, and thereby change the EMI behavioral.
> > >
> > > Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.
> > >
> > > Tested on Beaglebone Black with VSC 8531 PHY.
> > >
> > > Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> >
> > Applied, thanks.
> 
> Oh dear. It was not ready for acceptance yet. I guess you missed all
> the discussion because it was attached to the previous version of the
> patch.
> 
> Raju you now need to submit fixup patches relative to the version
> David has accepted, to fix the issues we were discussing.
> 

Accepted.

>       Andrew
> 
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
