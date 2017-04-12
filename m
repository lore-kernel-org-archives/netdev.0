From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v3] smsc95xx: Add comments to the registers definition
Date: Wed, 12 Apr 2017 14:25:18 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40A41DA1@CHN-SV-EXMX02.mchp-main.com>
References: <20170410084521.w2kdjpdquvrg72mr@SMX-2>
 <20170410135251.GC19820@lunn.ch>
 <20170411.221836.113758478587841074.davem@davemloft.net>
 <20170412092405.doyczwsqnzkizarz@SMX-2>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <steve.glendinning@shawell.net>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-usb@vger.kernel.org>
To: <martin@wetterwald.eu>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa2.microchip.iphmx.com ([68.232.149.84]:16071 "EHLO
        esa2.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752384AbdDLOZV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Apr 2017 10:25:21 -0400
In-Reply-To: <20170412092405.doyczwsqnzkizarz@SMX-2>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +/* LED General Purpose IO Configuration Register */
> +#define LED_GPIO_CFG		(0x24)
> +#define LED_GPIO_CFG_SPD_LED	(0x01000000)	/* GPIO2 as SPD LED
> */
> +#define LED_GPIO_CFG_LNK_LED	(0x00100000)	/* GPIO1 as LNK LED
> */
> +#define LED_GPIO_CFG_FDX_LED	(0x00010000)	/* GPIO0 as FDX LED
> */
Because comments are one of main reason for this patch.
It is GPIO 10, 9 & 8.

Woojung
