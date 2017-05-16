From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] net/smc: mark as BROKEN due to remote memory exposure
Date: Tue, 16 May 2017 12:33:08 -0400 (EDT)
Message-ID: <20170516.123308.2059131411772131424.davem@davemloft.net>
References: <1494950224.3259.98.camel@redhat.com>
        <20170516.122923.869994491617365845.davem@davemloft.net>
        <20170516163041.GA5132@lst.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org,
        torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, stable-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: hch-jcswGhMUV9g@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170516163041.GA5132-jcswGhMUV9g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date: Tue, 16 May 2017 18:30:41 +0200

> On Tue, May 16, 2017 at 12:29:23PM -0400, David Miller wrote:
>> I can't push back on people with silly coding style and small semantic
>> issues forever.  And I think I made a serious effort to keep the
>> patches getting posted over and over again to make sure they got more
>> exposure.
> 
> You can tell them to go to linux-rdma.  I'm sending people to the right
> mailing list all the time.

That doesn't cover things that don't directly touch the RDMA code or
infiniband infrastructure.

There should have been RDMA people on netdev who saw this thing and
cried wolf, and they would have had about an entire year, and about
8 instances of this series being posted in which to do so.

It's not like this got posted once or twice and went in with zero
review.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
