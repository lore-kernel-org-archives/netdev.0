From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [pull request][for-next 0/8] Mellanox, mlx5 shared 2017-08-07
Date: Mon, 07 Aug 2017 11:20:52 -0700 (PDT)
Message-ID: <20170807.112052.332868856082904160.davem@davemloft.net>
References: <20170807101808.22924-1-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
To: saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170807101808.22924-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Date: Mon,  7 Aug 2017 13:18:00 +0300

> Hi Dave & Doug,
> 
> This series contains some low level updates for mlx5 core driver,
> to be shared as base code for net-next and rdma for-next mlx5
> 4.14 submissions.
> 
> Please find more information in the tag message below.
> 
> Please pull and let me know if there's any porblem.
> 
> Side note:
> This series merges cleanly with current net-next, but it will conflict with Jiri's patch
> "mlx5e: push cls_flower and mqprio setup_tc processing into separate functions"
> Which is under review.
> since this is shared code and must go to both rdma and net-next it has to be
> based on 4.13-rc4, so there is not much I can do about this.

I resolved the merge conflict as best as I could, please take a look.

Pulled, thanks.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
