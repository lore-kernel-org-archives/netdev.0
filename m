From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: net-next pull request: RDS
Date: Thu, 09 Sep 2010 14:58:36 -0700 (PDT)
Message-ID: <20100909.145836.59673428.davem@davemloft.net>
References: <4C892C9C.4060304@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4C892C9C.4060304-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Andy Grover <andy.grover-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Thu, 09 Sep 2010 11:51:08 -0700

> Hi Dave,
> 
> Sorry for the "release late, release seldom". We've made a lot of
> changes since spring but it never really stabilized..
> 
> Summary:
>   * Add atomic operations (cswp and fadd) and masked versions
>   * New RDS_RDMA_SILENT flag will try to execute RDMA op without
>     causing an interrupt on the target machine
>   * Massive performance improvements on big boxes (Chris Mason)
>   * Many rmmod refcounting fixes (Zach Brown)
>   * Do much more from tasklets instead of the worker thread
>   * Add rds.h to kernel exported headers list
>   * Other cleanups

I'll pull, but yeah you guys have to sync with me a lot more
often.

It would be nice if you guys CC:'d netdev for every patch that ends
up in your tree as well.

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
