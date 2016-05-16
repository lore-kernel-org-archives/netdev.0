From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net] net/mlx4_core: Fix access to uninitialized index
Date: Mon, 16 May 2016 13:58:32 -0400 (EDT)
Message-ID: <20160516.135832.1771202592587427917.davem@davemloft.net>
References: <1463296886-4364-1-git-send-email-tariqt@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463296886-4364-1-git-send-email-tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Sun, 15 May 2016 10:21:26 +0300

> Prevent using uninitialized or negative index when handling
> steering entries.
> 
> Fixes: b12d93d63c32 ('mlx4: Add support for promiscuous mode in the new steering model.')
> Signed-off-by: Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> Reported-by: Dan Carpenter <dan.carpenter-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>

Applied.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
