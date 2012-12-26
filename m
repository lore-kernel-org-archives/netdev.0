From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] netprio_cgroup: define sk_cgrp_prioidx only if
 NETPRIO_CGROUP is enabled
Date: Wed, 26 Dec 2012 14:16:42 -0800 (PST)
Message-ID: <20121226.141642.2212856687052645929.davem@davemloft.net>
References: <50DA9DB8.6080506@huawei.com>
	<20121226180339.GB10793@neilslaptop.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20121226180339.GB10793-0o1r3XBGOEbbgkc5XkKeNuvMHUBZFtU3YPYVAmT7z5s@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Date: Wed, 26 Dec 2012 13:03:39 -0500

> On Wed, Dec 26, 2012 at 02:48:24PM +0800, Li Zefan wrote:
>> sock->sk_cgrp_prioidx won't be used at all if CONFIG_NETPRIO_CGROUP=n.
>> 
>> Signed-off-by: Li Zefan <lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Acked-by: Neil Horman <nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>

Applied, thanks.
