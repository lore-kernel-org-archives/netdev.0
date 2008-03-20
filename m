From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH/RFC v2] introduce ARCH_CAN_UNALIGNED_ACCESS Kconfig
 symbol
Date: Thu, 20 Mar 2008 15:10:54 -0700 (PDT)
Message-ID: <20080320.151054.41532763.davem@davemloft.net>
References: <20080320.141307.173590705.davem@davemloft.net>
	<1206048106.16475.161.camel@johannes.berg>
	<20080320220348.GC1330@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, sam-uyr5N9Q2VtJg9hUCZPvPmw@public.gmane.org, dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080320220348.GC1330-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Thu, 20 Mar 2008 18:03:48 -0400

> While I think Dave has a point, I don't think you should labor the word
> choice too much.  Try to document it as clearly as possible and hope
> for the best -- I hear that the arch maintainers are top notch! :-)

I think the name of the macro is very important.

Non-arch people will see this thing and wonder what in the
world it means.  You can document something with kerneldoc
foo as much as you like, still the initial impression the
reader gets from the name is of utmost importance.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
