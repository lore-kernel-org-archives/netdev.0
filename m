From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH 2/3] net/mlx5e: make VXLAN support conditional
Date: Fri, 06 May 2016 15:35:56 -0400 (EDT)
Message-ID: <20160506.153556.1442520532117922001.davem@davemloft.net>
References: <1462365116-3856622-1-git-send-email-arnd@arndb.de>
	<CALzJLG885q-Nm4xD3FobvY4A9RhLAV3jLwfAWdJwyDOid+tJ6g@mail.gmail.com>
	<4306900.EI0LQtX7kx@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	galp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: arnd-r2nGTMty4D4@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4306900.EI0LQtX7kx@wuerfel>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Date: Thu, 05 May 2016 20:09:19 +0200

> For reference, I've tried it out on the MLX4 driver, and it does
> seem nicer that way, see below.

Is it possible to wind down this conversation and have someone submit
whatever final patch everyone agrees to?

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
