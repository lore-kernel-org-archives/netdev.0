From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next v5 0/2] stmmac: fix kernel crashes for jumbo
 frames
Date: Sun, 19 Jan 2014 20:04:31 -0800 (PST)
Message-ID: <20140119.200431.44766674079788350.davem@davemloft.net>
References: <1389903026-12064-1-git-send-email-vbridgers2013@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	peppe.cavallaro-qxv4g6HH51o@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, dinguyen-EIB2kfCEclfQT0dZR+AlfA@public.gmane.org, rayagond-AmucfkJibqKGw+nKnLezzg@public.gmane.org
To: vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1389903026-12064-1-git-send-email-vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vince Bridgers <vbridgers2013-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Thu, 16 Jan 2014 14:10:24 -0600

> These patches address two kernel crashes seen when using jumbo frames on 
> the Synopsys stmmac driver, and adds device tree configurability for the 
> maximum mtu. The Synopsys emac fifo sizes can be configured when a logic
> design is synthesized, but does not provide a way for a driver to query the
> exact fifo size. 

These patches do not apply to the current net-next tree, please respin.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
