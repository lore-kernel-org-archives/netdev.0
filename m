From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH for/net-next 3/8] net/mlx5: Mellanox Connect-IB, core
 driver part 3/3
Date: Mon, 01 Jul 2013 12:17:27 -0700 (PDT)
Message-ID: <20130701.121727.478865363404777778.davem@davemloft.net>
References: <1372256537-21328-4-git-send-email-ogerlitz@mellanox.com>
	<20130628.211041.256072234719301298.davem@davemloft.net>
	<201307011444.55361.jackm@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org, moshel-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <201307011444.55361.jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Jack Morgenstein <jackm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Date: Mon, 1 Jul 2013 14:44:54 +0300

> Thus, the "for" loop could read:
> 	for (--i; i >= 0; i--) {
> 
> However, my own personal opinion is that this is a bit confusing.
> I would prefer to leave these lines as they are.
> 
> Is that OK with you?

Please adjust the right-most increment.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
