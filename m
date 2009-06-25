From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 07/10] decnet: Use rcu_barrier() on module unload.
Date: Thu, 25 Jun 2009 16:10:46 -0700 (PDT)
Message-ID: <20090625.161046.19938291.davem@davemloft.net>
References: <1245845367.24921.3.camel@localhost.localdomain>
	<5A680E0A-EFEB-44EA-9F06-F338E6CBD6D1@googlemail.com>
	<1245930729.24921.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org, paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	dougthompson-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org, kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org,
	yoshfuji-VfPWfsRibaP+Ru+s062T9g@public.gmane.org, shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org,
	linux-ext4-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tytso-3s7WtUTddSA@public.gmane.org, adilger-xsfywfwIY+M@public.gmane.org,
	netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: jdb-4UpuNZONu4c@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1245930729.24921.67.camel-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jesper Dangaard Brouer <jdb-4UpuNZONu4c@public.gmane.org>
Date: Thu, 25 Jun 2009 13:52:09 +0200

> On Wed, 2009-06-24 at 14:50 +0100, Chrissie Caulfield wrote:
>> I don't have any objection to the patch at all, 
> 
> Thus assuming an:
> 
> Acked-by: Chrissie Caulfield <christine.caulfield-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
> 
> (wondering if patchworks picks this up...)

It usually does.

However, could you formally resubmit just the networking bits
as that would make life a lot easier for me.

Thanks a lot Jesper!
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
