From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH rdma-next 07/19] RDMA/core: Add iterator over ib_devices
Date: Wed, 21 Jun 2017 09:07:35 -0500
Message-ID: <022201d2ea97$bb622b60$32268220$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-8-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain;
        charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'Chien Tin Tung'" <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        "'Stephen Hemminger'" <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        "'Jiri Pirko'" <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "'Ariel Almog'" <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        "'Linux Netdev'" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "'Leon Romanovsky'" <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "'Leon Romanovsky'" <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "'Doug Ledford'" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170621060528.3752-8-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> The coming nldev needs iterate over all IB devices in the system
> and in order do not expose the ib_devices list outside the devices.c,
> it is necessary to provide function iterator.

nit: "needs iterate over" -> "needs to iterate over..."
nit: "order do" -> "order to"

> 
> Current version is written explicitly for nldev callback to avoid
> over-engineering at this stage, but it can be easily extended for
> other types.
> 
> Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>


Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
