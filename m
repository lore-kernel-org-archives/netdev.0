From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [patch] net/mlx5: remove a duplicate condition
Date: Fri, 25 Nov 2016 20:30:17 -0500 (EST)
Message-ID: <20161125.203017.430757314871566294.davem@davemloft.net>
References: <20161124110345.GC17225@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, kernel-janitors-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161124110345.GC17225@mwanda>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Date: Thu, 24 Nov 2016 14:03:45 +0300

> We verified that MLX5_FLOW_CONTEXT_ACTION_COUNT was set on the first
> line of the function so we don't need to check again here.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
