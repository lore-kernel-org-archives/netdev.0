From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] mlx5: use after free in mlx5_cmd_comp_handler()
Date: Wed, 24 Jul 2013 15:45:14 -0700 (PDT)
Message-ID: <20130724.154514.498183770995136243.davem@davemloft.net>
References: <20130722080201.GG14617@longonot.mountain>
	<20130724163544.GA29427@mtldesk30>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130724163544.GA29427@mtldesk30>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Wed, 24 Jul 2013 19:35:44 +0300

> This race has been spotted and fixed by Moshe Lazer two weeks ago.
> Anyways,
> 
> Acked by Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
