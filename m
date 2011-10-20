From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
Subject: Re: [PATCH 07/10] RDMA/cxgb4: DB Drop Recovery for RDMA and LLD queues.
Date: Thu, 20 Oct 2011 10:17:11 -0700
Message-ID: <CAL1RGDUDk_MAM+S+MaEcPQzug8TvE-mFAfNqX3FqRApLQu9H2g@mail.gmail.com>
References: <1319044264-779-1-git-send-email-vipul@chelsio.com>
 <1319044264-779-8-git-send-email-vipul@chelsio.com> <CAL1RGDWCfJHD+PjXQ3STk4uc-fEyQ2GsQR5ALU6i4-f7w2bXUA@mail.gmail.com>
 <4EA030F5.3000007@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org,
	dm-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org, kumaras-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4EA030F5.3000007-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> I believe 5 and 7 have build dependencies.

Right, missed that one too.

But it seems 4,6,8,9,10 are independent of the rest of the series?

ie I can trivially apply them and then worry about working out
the drivers/net / drivers/infiniband interdependency a bit later?

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
