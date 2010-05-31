From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] mlx4_en: use net_device dev_id to indicate port number
Date: Mon, 31 May 2010 00:33:02 -0700 (PDT)
Message-ID: <20100531.003302.70210008.davem@davemloft.net>
References: <20100527055624.GA18736@mtldesk030.lab.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org
To: eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100527055624.GA18736-8YAHvHwT2UEvbXDkjdHOrw/a8Rv0c6iv@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Date: Thu, 27 May 2010 08:56:24 +0300

> Today, there are no means to know which port of a hardware device a netdev
> interface uses. struct net_device conatins a field, dev_id, that can be used
> for that. Use this field to save the port number in ConnectX that is being used
> by the net device; port numbers are zero based.
> 
> Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
