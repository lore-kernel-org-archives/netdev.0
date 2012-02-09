From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next] gro: more generic L2 header check
Date: Thu, 09 Feb 2012 17:28:31 -0500 (EST)
Message-ID: <20120209.172831.1366859709918853798.davem@davemloft.net>
References: <CAJZOPZJj=rBoss-JiLm6K66D1h+zyerDspDS+358t7u=Mg2pfQ@mail.gmail.com>
	<20120209.152943.1123862542883793404.davem@davemloft.net>
	<CAJZOPZKUG-tT+Zd=1EiLhgRxg4VEDrisBJQ99XtARMvK68UWfA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAJZOPZKUG-tT+Zd=1EiLhgRxg4VEDrisBJQ99XtARMvK68UWfA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Fri, 10 Feb 2012 00:18:30 +0200

> On Thu, Feb 9, 2012 at 10:29 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
>> I cannot rebase my tree, too many people use it and I would break
>> their stuff. We simply have to live with this error.
> 
> I see, so you will add CC to stable, such that they will be picked
> into -stable once you push them to Linus?

This is so tiring explaining all of this stuff...

I submit stable patches for networking directly myself, at a time of
my own choosing, once I believe that the changes have had enough
exposure and testing.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
