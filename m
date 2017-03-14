From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCHv3 0/4] rds: ib: trivial patches
Date: Mon, 13 Mar 2017 23:20:23 -0700 (PDT)
Message-ID: <20170313.232023.812288063688948196.davem@davemloft.net>
References: <1489383828-7699-1-git-send-email-yanjun.zhu@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1489383828-7699-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Mon, 13 Mar 2017 01:43:44 -0400

> v2 -> v3
> remove err from messages.
> 
> Zhu Yanjun (4):
>   rds: ib: drop unnecessary rdma_reject
>   rds: ib: remove redundant ib_dealloc_fmr
>   rds: ib: add the static type to the function
>   rds: ib: unmap the scatter/gather list when error

Series applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
