From: Hariprasad S <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCHv3 net-next 00/31] Misc. fixes for cxgb4 and iw_cxgb4
Date: Wed, 5 Mar 2014 11:00:25 +0530
Message-ID: <20140305053024.GA23862@hariprasad-pc>
References: <1393936917-25847-1-git-send-email-hariprasad@chelsio.com>
 <20140304.132226.75524344104026791.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>, <kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>, <leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<santosh-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, <nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140304.132226.75524344104026791.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 04, 2014 at 13:22:26 -0500, David Miller wrote:
> 
> BTW, if you're frustrated from having to send these patches so many
> times because of changes being requested, this is the main reason
> why you shouldn't queue up such enormous numbers of patches at one
> time.
> 
> Please try to keep your future submissions sizes more reasonable,
> perhaps ~10 patches or so at most.
> 
> Thanks.

Sure, thanks for the suggestion.
I will just re-post the revert patch on cxgb4 now, part of this series, which is 
causing regression.
And, I will split the rest of patch-series into 8-10 patches and re-submit.


Thanks for the review comments!
-Hari.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
