From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [net-next] net: dwc-xlgmac: add module license
Date: Wed, 22 Mar 2017 10:53:14 -0700 (PDT)
Message-ID: <20170322.105314.1598893528436587108.davem@davemloft.net>
References: <20170320085123.1032301-1-arnd@arndb.de>
        <20170320085123.1032301-2-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiedeng@synopsys.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42192 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935398AbdCVRxQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 13:53:16 -0400
In-Reply-To: <20170320085123.1032301-2-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Mon, 20 Mar 2017 09:51:13 +0100

> When building the driver as a module, we get a warning about the
> lack of a license:
> 
> WARNING: modpost: missing MODULE_LICENSE() in drivers/net/ethernet/synopsys/dwc-xlgmac.o
> see include/linux/module.h for more information
> 
> Curiously the text in the .c files only mentions GPLv2+, while the license
> tag in the PCI driver contains both GPL and BSD. I picked the license text
> as the more definite reference here and put a GPL tag in there.
> 
> Fixes: 65e0ace2c5cd ("net: dwc-xlgmac: Initial driver for DesignWare Enterprise Ethernet")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied.
