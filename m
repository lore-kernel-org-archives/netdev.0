From: Mauro Carvalho Chehab <mchehab-JsYNTwtnfakRB7SZvlqPiA@public.gmane.org>
Subject: Re: [PATCH] treewide: Correct diffrent[iate] and banlance typos
Date: Fri, 31 Mar 2017 07:06:25 -0300
Message-ID: <20170331070625.39294170@vento.lan>
References: <962aace119675e5fe87be2a88ddac1a5486f8e60.1490931810.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        Ariel Elior <ariel.elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>,
        everest-linux-l2-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org, Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Mauro Carvalho Chehab <mchehab-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Yisen Zhuang <yisen.zhuang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>,
        linux-media-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <962aace119675e5fe87be2a88ddac1a5486f8e60.1490931810.git.joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Thu, 30 Mar 2017 20:44:16 -0700
Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> escreveu:

> Add these misspellings to scripts/spelling.txt too
> 
> Signed-off-by: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
> ---
>  drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h | 2 +-
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c      | 2 +-
>  drivers/net/ethernet/hisilicon/hns/hns_enet.c       | 2 +-
>  drivers/net/ethernet/qlogic/qed/qed_int.c           | 2 +-
>  drivers/net/ethernet/qlogic/qed/qed_main.c          | 2 +-
>  drivers/net/ethernet/qlogic/qed/qed_sriov.c         | 2 +-
>  include/linux/mlx4/device.h                         | 2 +-
>  scripts/spelling.txt                                | 3 +++
>  8 files changed, 10 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h b/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
> index 354ec07eae87..23ae72468025 100644
> --- a/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
> +++ b/drivers/media/dvb-frontends/drx39xyj/drx_dap_fasi.h
> @@ -70,7 +70,7 @@
>  * (3) both long and short but short preferred and long only when necesarry
>  *
>  * These modes must be selected compile time via compile switches.
> -* Compile switch settings for the diffrent modes:
> +* Compile switch settings for the different modes:
>  * (1) DRXDAPFASI_LONG_ADDR_ALLOWED=0, DRXDAPFASI_SHORT_ADDR_ALLOWED=1
>  * (2) DRXDAPFASI_LONG_ADDR_ALLOWED=1, DRXDAPFASI_SHORT_ADDR_ALLOWED=0
>  * (3) DRXDAPFASI_LONG_ADDR_ALLOWED=1, DRXDAPFASI_SHORT_ADDR_ALLOWED=1
> diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> index cea6bdcde33f..8baf9d3eb4b1 100644
> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
> @@ -1591,7 +1591,7 @@ static int __bnx2x_vlan_mac_execute_step(struct bnx2x *bp,
>  	if (rc != 0) {
>  		__bnx2x_vlan_mac_h_pend(bp, o, *ramrod_flags);
>  
> -		/* Calling function should not diffrentiate between this case
> +		/* Calling function should not differentiate between this case
>  		 * and the case in which there is already a pending ramrod
>  		 */
>  		rc = 1;


Acked-by: Mauro Carvalho Chehab <mchehab-JsYNTwtnfakRB7SZvlqPiA@public.gmane.org>

Thanks,
Mauro
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
