From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] RDS: IB: Limit the scope of has_fr/has_fmr
 variables
Date: Sun, 01 Oct 2017 22:54:19 -0700 (PDT)
Message-ID: <20171001.225419.1632354964848604960.davem@davemloft.net>
References: <1506734030-15205-1-git-send-email-avinash.repaka@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1506734030-15205-1-git-send-email-avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Fri, 29 Sep 2017 18:13:50 -0700

> This patch fixes the scope of has_fr and has_fmr variables as they are
> needed only in rds_ib_add_one().
> 
> Signed-off-by: Avinash Repaka <avinash.repaka-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
