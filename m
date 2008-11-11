From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull request: wireless-next-2.6 2008-11-10
Date: Mon, 10 Nov 2008 16:18:51 -0800 (PST)
Message-ID: <20081110.161851.25101606.davem@davemloft.net>
References: <20081110204500.GL3546@tuxdriver.com>
	<20081110.133054.154011074.davem@davemloft.net>
	<1226361148.3650.22.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1226361148.3650.22.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 11 Nov 2008 00:52:28 +0100

> On Mon, 2008-11-10 at 13:30 -0800, David Miller wrote:
> 
> > BTW, I noticed that print_ssid() is a good candidate for a new
> > %pX format specifier extension, just like how we got rid of
> > print_mac(), NIPQUAD() and friends recently in the net-next
> > tree.
> 
> I was thinking about that too, but unless we want to do something like
> adding %pSSID I think we shouldn't do this for so few users.

Fair enough.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
