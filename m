From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mlx4: Fixing Ethernet unicast packet steering
Date: Wed, 03 Aug 2011 16:39:06 -0700 (PDT)
Message-ID: <20110803.163906.899795254925297005.davem@davemloft.net>
References: <4E39594C.4090808@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4E39594C.4090808-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Date: Wed, 3 Aug 2011 17:21:00 +0300

> 
> For older FW versions, fixing the usage of per port Mac table.
> For each port we must define the base QP number, which is passed
> to the HW.
> Setting the correct value in SET_PORT FW command to enable the steering.
> 
> Reported-by: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
> Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
