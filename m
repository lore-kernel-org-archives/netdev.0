From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 0/2] All Chelsio drivers : Cleanup CPL
 messages macros
Date: Mon, 12 Jan 2015 16:20:03 -0500 (EST)
Message-ID: <20150112.162003.158111167752709707.davem@davemloft.net>
References: <1420781896-25337-1-git-send-email-anish@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org,
	hariprasad-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org,
	kxie-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, leedom-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1420781896-25337-1-git-send-email-anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Anish Bhatt <anish-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Thu,  8 Jan 2015 21:38:14 -0800

> This patch series cleans up all register defines/MACROS defined in t4_msg.h and
> affected files as part of the continuing cleanup effort
> 
> The patches series is created against 'net-next' tree and  includes patches 
> to the cxgb4, cxgb4vf, iw_cxgb4, cxgb4i and csiostor drivers.
> 
> We have included all the maintainers of respective drivers. Kindly review the
> change and let us know in case of any review comments.

Looks fine, applied to net-next, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
