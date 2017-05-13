From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2 net-next 5/5] dsa: add maintainer of Microchip KSZ
 switches
Date: Sat, 13 May 2017 16:58:39 +0200
Message-ID: <20170513145839.GF14058@lunn.ch>
References: <9235D6609DB808459E95D78E17F2E43D40A632D5@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: f.fainelli@gmail.com, vivien.didelot@savoirfairelinux.com,
        sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
        davem@davemloft.net, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57735 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752134AbdEMO6l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 13 May 2017 10:58:41 -0400
Content-Disposition: inline
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A632D5@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 12, 2017 at 08:08:01PM +0000, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> Adding maintainer of Microchip KSZ switches.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>

> ---
>  MAINTAINERS | 9 +++++++++
>  1 file changed, 9 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 45b173a..e65e501 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -8370,6 +8370,15 @@ F:	drivers/media/platform/atmel/atmel-isc.c
>  F:	drivers/media/platform/atmel/atmel-isc-regs.h
>  F:	devicetree/bindings/media/atmel-isc.txt
>  
> +MICROCHIP KSZ SERIES ETHERNET SWITCH DRIVER
> +M:	Woojung Huh <Woojung.Huh@microchip.com>
> +M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	drivers/net/dsa/microchip/*
> +F:	include/linux/platform_data/microchip-ksz.h

Please add the tag_* files to this list.

Otherwise:

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

	     Andrew
