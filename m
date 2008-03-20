From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH/RFC v2] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
 symbol
Date: Thu, 20 Mar 2008 14:27:07 -0700 (PDT)
Message-ID: <20080320.142707.170694458.davem@davemloft.net>
References: <1206038373.16475.150.camel@johannes.berg>
	<20080320.141307.173590705.davem@davemloft.net>
	<1206048106.16475.161.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1206048106.16475.161.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Thu, 20 Mar 2008 22:21:46 +0100

> Yeah, good point. Should I rename it to HAVE_EFFICIENT_UNALIGNED_ACCESS
> or similar? Or have it defined as some sort of number so you can make
> actually make tradeoffs? Like Dave Woodhouse suggested at some point to
> have get_unaligned() take an argument that indicates the probability...

Yes, that name and something with a "score" of some sort would
be nice.

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
