From: Honggang LI <honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH linux-next v4] mlx5: wrong page mask if
 CONFIG_ARCH_DMA_ADDR_T_64BIT enabled for 32Bit architectures
Date: Wed, 15 Apr 2015 16:34:07 +0800
Message-ID: <20150415083407.GF4514@honli.nay.redhat.com>
References: <1429078919-28122-1-git-send-email-honli@redhat.com>
 <552E0F37.2080509@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <552E0F37.2080509-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 15, 2015 at 10:11:51AM +0300, Or Gerlitz wrote:
> On 4/15/2015 9:21 AM, Honggang Li wrote:
> >Fixes: bf0bf77f6519 ('mlx5: Support communicating arbitrary host page size to firmware')
> >
> >Signed-off-by: Honggang Li<honli-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
> ain't over... avoid the blank line between the Fixes tag to your SOB

Removed the blank line. New patch (v5) has been send out. Really hope it
is the finial one.

thanks

> >---
> >  drivers/net/ethernet/mellanox/mlx5/core/pagealloc.c | 10 ++++++----
> >  1 file changed, 6 insertions(+), 4 deletions(-)
> 
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
