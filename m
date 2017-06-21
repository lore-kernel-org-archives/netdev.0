From: "Steve Wise" <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: RE: [PATCH rdma-next 05/19] RDMA/netlink: Simplify and rename ibnl_chk_listeners
Date: Wed, 21 Jun 2017 09:04:09 -0500
Message-ID: <021e01d2ea97$41162fa0$c3428ee0$@opengridcomputing.com>
References: <20170621060528.3752-1-leon@kernel.org> <20170621060528.3752-6-leon@kernel.org>
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
In-Reply-To: <20170621060528.3752-6-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Content-Language: en-us
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> 
> Make ibnl_chk_listeners function to be one line by removing
> unneeded comparison.
> 
> Rename that function to be complaint to other functions in RDMA netlink.
> 
> Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>


Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
