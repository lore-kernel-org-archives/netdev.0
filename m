From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: pull-request: wireless-drivers-next 2016-09-29
Date: Fri, 30 Sep 2016 01:32:45 -0400 (EDT)
Message-ID: <20160930.013245.1474369794552343595.davem@davemloft.net>
References: <87ponmve2v.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87ponmve2v.fsf-HodKDYzPHsUD5k0oWYwrnHL1okKdlPRT@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Date: Thu, 29 Sep 2016 19:57:28 +0300

> this should be the last wireless-drivers-next pull request for 4.9, from
> now on only important bugfixes. Nothing really special stands out,
> iwlwifi being most active but other drivers also getting attention. More
> details in the signed tag. Please let me know if there are any problems.

Pulled, thanks Kalle.

> Or actually I had one problem. While doing a test merge I noticed that
> net-next fails to compile for me, but I don't think this is anything
> wireless related:
> 
>   CC      net/netfilter/core.o
> net/netfilter/core.c: In function 'nf_set_hooks_head':
> net/netfilter/core.c:96:149: error: 'struct net_device' has no member named 'nf_hooks_ingress'

Yes, I am aware of this build issue and will tackle it myself if someone
doesn't beat me to it.

Thanks again.
