From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] cpmac: add support for fixed PHY
Date: Wed, 05 Aug 2009 12:23:42 -0700 (PDT)
Message-ID: <20090805.122342.222976829.davem@davemloft.net>
References: <200908042252.53068.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54674
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751675AbZHETXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2009 15:23:33 -0400
In-Reply-To: <200908042252.53068.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Tue, 4 Aug 2009 22:52:52 +0200

> This patch adds support for fixed PHY connected in MII mode
> to cpmac. We allow external and dumb_switch module parameters
> to override the PHY detection process since they are always connected
> with MDIO bus identifier 0. This lets fixed PHYs to be detected
> correctly and be connected to the their corresponding MDIO
> bus identifier.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

Applied to net-next-2.6
