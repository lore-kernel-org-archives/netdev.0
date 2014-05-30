From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 1/2] emac: add missing support of 10mbit in emac/rgmii
Date: Fri, 30 May 2014 16:31:02 -0700 (PDT)
Message-ID: <20140530.163102.1981140061094569862.davem@davemloft.net>
References: <1401128657.24099.17.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, alistair-Y4h6yKqj69EXC2x5gXVKYQ@public.gmane.org,
	robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org
To: ivan-JgLE2wv1ufrQT0dZR+AlfA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1401128657.24099.17.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Ivan Mikhaylov <ivan-JgLE2wv1ufrQT0dZR+AlfA@public.gmane.org>
Date: Mon, 26 May 2014 22:24:17 +0400

> In chips of emac/rgmii b'000' for 0/1 channel isn't suitable which
> resulted in non working network interface in this mode.
> 
> Signed-off-by: Ivan Mikhaylov <ivan-JgLE2wv1ufrQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
