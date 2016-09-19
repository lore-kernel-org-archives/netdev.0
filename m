From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 0/2] cxgb4 FR_NSMR_TPTE_WR support
Date: Mon, 19 Sep 2016 10:29:20 -0400 (EDT)
Message-ID: <20160919.102920.1126387243122900012.davem@davemloft.net>
References: <cover.1474037695.git.swise@opengridcomputing.com>
        <20160919.011633.1357649774235825501.davem@davemloft.net>
        <007f01d21280$7d1556b0$77400410$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <007f01d21280$7d1556b0$77400410$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Date: Mon, 19 Sep 2016 09:17:01 -0500

> 
>> 
>> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
>> Date: Fri, 16 Sep 2016 07:54:55 -0700
>> 
>> > This series enables a new work request to optimize small REG_MR
>> > operations.  This is intended for 4.9.  If everyone agrees, I suggest
>> > Doug take both the cxgb4 and iw_cxgb4 patches through his tree.
>> 
>> I'm assuming this mean that I do _not_ apply these to my tree.
> 
> Yes, if you're ok with that. 

I am.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
