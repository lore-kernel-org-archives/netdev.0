From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next 2/3] Add LAN743X to Kconfig and Makefile (fwd)
Date: Mon, 14 Aug 2017 16:16:56 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264406F66E2@CHN-SV-EXMX02.mchp-main.com>
References: <alpine.DEB.2.20.1708141217280.3368@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>, <kbuild-all@01.org>
To: <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa1.microchip.iphmx.com ([68.232.147.91]:38993 "EHLO
        esa1.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752282AbdHNQRN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 12:17:13 -0400
In-Reply-To: <alpine.DEB.2.20.1708141217280.3368@hadrien>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't think netdev_priv can return NULL, so lines 6641 to 6646 could just be
> dropped.
> 
> julia
> 

Julia,

Thanks for the feedback.
I will make changes and submit again later.

Bryan
