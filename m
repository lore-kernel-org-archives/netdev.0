From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/5] RDMA/cxgb4,cxgb4vf,csiostor: Cleanup
 macros
Date: Sat, 22 Nov 2014 16:58:11 -0500 (EST)
Message-ID: <20141122.165811.2270530256951559796.davem@davemloft.net>
References: <1416554525-11844-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	nirranjan-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, praveen-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	varun-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1416554525-11844-1-git-send-email-hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Hariprasad Shenai <hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Fri, 21 Nov 2014 12:52:00 +0530

> This series continues to cleanup all the macros/register defines related to
> filter, port, VI, queue, RSS, LDST, firmware, etc that are defined in t4fw_api.h
> and the affected files.
> 
> Will post few more series so that we can cover all the macros so that they all
> follow the same style to be consistent.
> 
> The patches series is created against 'net-next' tree.
> And includes patches on cxgb4, cxgb4vf, iw_cxgb4 and csiostor driver.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Series applied, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
