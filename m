From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 13 May 2008 02:45:16 -0700 (PDT)
Message-ID: <20080513.024516.248213393.davem@davemloft.net>
References: <1209936745.7304.16.camel@johannes.berg>
	<20080512.205224.12536510.davem@davemloft.net>
	<1210669273.3646.51.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1210669273.3646.51.camel-YfaajirXv214zXjbi5bjpg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Date: Tue, 13 May 2008 11:01:13 +0200

> Will you put in something like the patch that made dev_alloc_skb
> reserve more with the bridging headroom as well, or do you want (me)
> to look at routing first?

I'm trying to do this one set of changes at a time. :-)

I'll get to the netdev_alloc_skb() bits after this stuff
has had some time to cook.
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
