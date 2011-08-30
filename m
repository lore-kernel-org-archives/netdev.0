From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 19/24] sunrpc: Remove unnecessary OOM logging messages
Date: Mon, 29 Aug 2011 22:35:28 -0400 (EDT)
Message-ID: <20110829.223528.1015352328965337938.davem@davemloft.net>
References: <4E5C0AB3.90401@panasas.com>
	<20110829.180348.1774953636752413432.davem@davemloft.net>
	<2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF@SACMVEXC2-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bharrosh-C4P08NqkoRlBDgjK7y7TUQ@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	neilb-l3A5Bk7waGM@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2E1EB2CF9ED1CB4AA966F0EB76EAB4430AEB4FAF-hX7t0kiaRRrlMGe9HJ1VYQK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Myklebust, Trond" <Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>
Date: Mon, 29 Aug 2011 16:25:08 -0700

> I can see that slub.c has the slab_out_of_memory() function that
> (although ratelimited) warns you if the allocation failed. However I
> can't find any equivalent for slab.c or slob.c.

See the page allocator.
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
