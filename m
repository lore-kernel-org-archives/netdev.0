From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v5 net-next 0/5] dsa: add Microchip KSZ9477 DSA driver
Date: Wed, 31 May 2017 18:56:12 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AA5479@CHN-SV-EXMX02.mchp-main.com>
References: <9235D6609DB808459E95D78E17F2E43D40AA4D4C@CHN-SV-EXMX02.mchp-main.com>
        <20170531.142830.1153280352895864825.davem@davemloft.net>
 <20170531.144732.768135527494752476.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <andrew@lunn.ch>, <f.fainelli@gmail.com>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:55051 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750977AbdEaS4O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 14:56:14 -0400
In-Reply-To: <20170531.144732.768135527494752476.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Unfortunately, I had to revert, you didn't add MODULE_LICENSE() tags
> to the new drivers.
> 
> WARNING: modpost: missing MODULE_LICENSE() in
> drivers/net/dsa/microchip/ksz_common.o
> see include/linux/module.h for more information
> WARNING: modpost: missing MODULE_LICENSE() in
> drivers/net/dsa/microchip/ksz_spi.o
> see include/linux/module.h for more information
Ouch! Will submit update soon.

Thanks.
- Woojung
