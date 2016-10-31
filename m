From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH v2 net-next]
Date: Mon, 31 Oct 2016 21:05:51 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D4095CA4B@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <UNGLinuxDriver@microchip.com>
To: <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>,
        <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp03.microchip.com ([198.175.253.49]:47011 "EHLO
        email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S946883AbcJaVFx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 17:05:53 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Woojung Huh - C21699
> Sent: Monday, October 31, 2016 5:04 PM
> To: davem@davemloft.net; 'Florian Fainelli'; andrew@lunn.ch;
> netdev@vger.kernel.org
> Cc: UNGLinuxDriver
> Subject: [PATCH v2 net-next]
> 
> From: Woojung Huh <woojung.huh@microchip.com>
> 
> To utilize phylib with interrupt fully than handling some of phy stuff in the
> MAC driver,
> create irq_domain for USB interrupt EP of phy interrupt and
> pass the irq number to phy_connect_direct() instead of
> PHY_IGNORE_INTERRUPT.
> 
> Idea comes from drivers/gpio/gpio-dl2.c
> 
> Signed-off-by: Woojung Huh <woojung.huh@microchip.com>

Oops! Ignore this email. No subject.
Will submit another one.

Sorry about spam.
