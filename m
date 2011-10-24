From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 07/10] RDMA/cxgb4: DB Drop Recovery for RDMA and LLD
 queues.
Date: Mon, 24 Oct 2011 17:12:09 -0400 (EDT)
Message-ID: <20111024.171209.1856294221956226756.davem@davemloft.net>
References: <4EA05A27.9090605@opengridcomputing.com>
	<20111020.165703.1713724038045504243.davem@davemloft.net>
	<4EA5814F.6080801@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org, roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EA5814F.6080801-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
Date: Mon, 24 Oct 2011 20:46:31 +0530

> 1. We would like to recommend that all the patches get included in
> Roland's infiniband tree since it has build dependencies.

This is fine with me.  It just means that Roland's tree has to have
net-next included in it already, because otherwise the paths to
the cxgb4 driver under drivers/net won't be right.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
