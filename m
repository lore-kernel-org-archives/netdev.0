From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 2/3] net/mlx5e: make VXLAN support conditional
Date: Thu, 12 May 2016 10:15:08 +0200
Message-ID: <7520028.gr0eEEeEF0@wuerfel>
References: <1462365116-3856622-1-git-send-email-arnd@arndb.de> <20160506.153556.1442520532117922001.davem@davemloft.net> <CALzJLG_rkLvgKE2WnmU_CsdTFaYHEaYhnxyPtTkyQ4hjxdzRMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Matthew Finlay <matt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Amir Vadai <amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramonvsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Maor Gottlieb <maorg-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Gal Pressman <galp-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG_rkLvgKE2WnmU_CsdTFaYHEaYhnxyPtTkyQ4hjxdzRMQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sunday 08 May 2016 14:58:38 Saeed Mahameed wrote:
> On Fri, May 6, 2016 at 10:35 PM, David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote:
> > From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
> > Date: Thu, 05 May 2016 20:09:19 +0200
> >
> >> For reference, I've tried it out on the MLX4 driver, and it does
> >> seem nicer that way, see below.
> >
> > Is it possible to wind down this conversation and have someone submit
> > whatever final patch everyone agrees to?
> >
> 
> Yes, Just reposted to net what Arnd originally posted to net-next.
> "[PATCH net 0/2] net/mlx5e: Kconfig fixes for VxLAN"
> [...]
> Arnd Bergmann (2):
>   Revert "net/mlx5: Kconfig: Fix MLX5_EN/VXLAN build issue"
>   net/mlx5e: make VXLAN support conditional
> 
> I just rebased the patches on top of net.
> 
> Arnd please have a look.

Sorry for the delay, it looks all fine now and I see no more warnings.

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
