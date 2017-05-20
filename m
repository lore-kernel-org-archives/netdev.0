From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v3 net-next 5/5] dsa: add maintainer of Microchip KSZ
 switches
Date: Fri, 19 May 2017 17:03:53 -0700
Message-ID: <8fd3ad04-5675-192d-5993-f1dfd37b0fac@gmail.com>
References: <9235D6609DB808459E95D78E17F2E43D40A7C038@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com
To: Woojung.Huh@microchip.com, andrew@lunn.ch, davem@davemloft.net,
        sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34997 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932842AbdETAD6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 19 May 2017 20:03:58 -0400
Received: by mail-wm0-f68.google.com with SMTP id g15so1243241wmc.2
        for <netdev@vger.kernel.org>; Fri, 19 May 2017 17:03:57 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A7C038@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2017 03:57 PM, Woojung.Huh@microchip.com wrote:
> From: Woojung Huh <Woojung.Huh@microchip.com>
> 
> Adding maintainer of Microchip KSZ switches.
> 
> Signed-off-by: Woojung Huh <Woojung.Huh@microchip.com>
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
>  MAINTAINERS | 10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/MAINTAINERS b/MAINTAINERS
> index f7d568b..a72b40c 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -8454,6 +8454,16 @@ F:	drivers/media/platform/atmel/atmel-isc.c
>  F:	drivers/media/platform/atmel/atmel-isc-regs.h
>  F:	devicetree/bindings/media/atmel-isc.txt
>  
> +MICROCHIP KSZ SERIES ETHERNET SWITCH DRIVER
> +M:	Woojung Huh <Woojung.Huh@microchip.com>
> +M:	Microchip Linux Driver Support <UNGLinuxDriver@microchip.com>
> +L:	netdev@vger.kernel.org
> +S:	Maintained
> +F:	net/dsa/tag_ksz.c
> +F:	drivers/net/dsa/microchip/*
> +F:	include/linux/platform_data/microchip-ksz.h
> +F:	Documentation/devicetree/bindings/net/dsa/ksz.txt
> +
>  MICROCHIP USB251XB DRIVER
>  M:	Richard Leitner <richard.leitner@skidata.com>
>  L:	linux-usb@vger.kernel.org
> 


-- 
Florian
