From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH 0/2] cxgb4 FR_NSMR_TPTE_WR support
Date: Tue, 27 Sep 2016 17:03:44 -0500
Message-ID: <023401d2190b$03b00e50$0b102af0$@opengridcomputing.com>
References: <cover.1474037695.git.swise@opengridcomputing.com>        <20160919.011633.1357649774235825501.davem@davemloft.net>        <007f01d21280$7d1556b0$77400410$@opengridcomputing.com> <20160919.102920.1126387243122900012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'David Miller'" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: "'Doug Ledford'" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160919.102920.1126387243122900012.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> 
> >
> >>
> >> From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
> >> Date: Fri, 16 Sep 2016 07:54:55 -0700
> >>
> >> > This series enables a new work request to optimize small REG_MR
> >> > operations.  This is intended for 4.9.  If everyone agrees, I suggest
> >> > Doug take both the cxgb4 and iw_cxgb4 patches through his tree.
> >>
> >> I'm assuming this mean that I do _not_ apply these to my tree.
> >
> > Yes, if you're ok with that.
> 
> I am.

Doug, please include this for 4.9 if it looks good to you.  Let me know.

Thanks,

Steve.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
