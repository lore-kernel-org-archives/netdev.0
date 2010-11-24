From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] infiniband: remove dev_base_lock use
Date: Wed, 24 Nov 2010 09:09:57 -0800 (PST)
Message-ID: <20101124.090957.104052452.davem@davemloft.net>
References: <1288350226.2560.11.camel@edumazet-laptop>
	<1290606468.3464.38.camel@edumazet-laptop>
	<adalj4ihcsa.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org,
	sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adalj4ihcsa.fsf-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Date: Wed, 24 Nov 2010 09:06:13 -0800

>  > David, it seems no infiniband guy commented this patch, could you take
>  > it in your tree ?
> 
> Sorry... in any case this looks fine.  If all prerequisites are upstream
> then I'm happy to take through my tree, but if Dave wants to take it:
> 
> Acked-by: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>

I'd rather take it because it opens up some further simplifications
Eric wants to perform.

So I'll apply this to net-next-2.6, thanks for the review Roland.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
