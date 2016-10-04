From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v5 net-next] net: phy: Add Edge-rate driver for
 Microsemi PHYs.
Date: Tue, 04 Oct 2016 00:48:59 -0400 (EDT)
Message-ID: <20161004.004859.1105270097322633239.davem@davemloft.net>
References: <1475479393-24308-1-git-send-email-Raju.Lakkaraju@microsemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Allan.Nielsen-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org, andrew-g2DYL2Zd6BY@public.gmane.org
To: Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1475479393-24308-1-git-send-email-Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
Date: Mon, 3 Oct 2016 12:53:13 +0530

> From: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>
> 
> Edge-rate:
> As system and networking speeds increase, a signal's output transition,
> also know as the edge rate or slew rate (V/ns), takes on greater importance
> because high-speed signals come with a price. That price is an assortment of
> interference problems like ringing on the line, signal overshoot and
> undershoot, extended signal settling times, crosstalk noise, transmission
> line reflections, false signal detection by the receiving device and
> electromagnetic interference (EMI) -- all of which can negate the potential
> gains designers are seeking when they try to increase system speeds through
> the use of higher performance logic devices. The fact is, faster signaling
> edge rates can cause a higher level of electrical noise or other type of
> interference that can actually lead to slower line speeds and lower maximum
> system frequencies. This parameter allow the board designers to change the
> driving strange, and thereby change the EMI behavioral.
> 
> Edge-rate parameters (vddmac, edge-slowdown) get from Device Tree.
> 
> Tested on Beaglebone Black with VSC 8531 PHY.
> 
> Signed-off-by: Raju Lakkaraju <Raju.Lakkaraju-dzo6w/eZyo2tG0bUXCXiUA@public.gmane.org>

Applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
