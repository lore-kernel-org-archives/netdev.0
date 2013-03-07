From: Tony Lindgren <tony@atomide.com>
Subject: Re: [PATCH 2/3] arm: dts: am33xx: add default ethtool slave to
 cpsw node
Date: Thu, 7 Mar 2013 08:13:08 -0800
Message-ID: <20130307161308.GW11806@atomide.com>
References: <1362659421-11884-1-git-send-email-mugunthanvnm@ti.com>
 <1362659421-11884-3-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-omap@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mho-04-ewr.mailhop.org ([204.13.248.74]:22292 "EHLO
	mho-02-ewr.mailhop.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754830Ab3CGQNM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 11:13:12 -0500
Content-Disposition: inline
In-Reply-To: <1362659421-11884-3-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Mugunthan V N <mugunthanvnm@ti.com> [130307 04:35]:

Can you please add a description and send this separately
so Benoit can queue it.

Thanks,

Tony

> Signed-off-by: Mugunthan V N <mugunthanvnm@ti.com>
> ---
>  arch/arm/boot/dts/am33xx.dtsi |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/arch/arm/boot/dts/am33xx.dtsi b/arch/arm/boot/dts/am33xx.dtsi
> index 0957645..f8c83a1 100644
> --- a/arch/arm/boot/dts/am33xx.dtsi
> +++ b/arch/arm/boot/dts/am33xx.dtsi
> @@ -352,6 +352,7 @@
>  			cpts_active_slave = <0>;
>  			cpts_clock_mult = <0x80000000>;
>  			cpts_clock_shift = <29>;
> +			ethtool-active-slave = <0>;
>  			reg = <0x4a100000 0x800
>  			       0x4a101200 0x100>;
>  			#address-cells = <1>;
> -- 
> 1.7.9.5
> 
> _______________________________________________
> devicetree-discuss mailing list
> devicetree-discuss@lists.ozlabs.org
> https://lists.ozlabs.org/listinfo/devicetree-discuss
