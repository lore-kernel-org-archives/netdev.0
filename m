From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: fix kernel-doc warnings
Date: Mon, 05 Jun 2017 11:29:09 -0400 (EDT)
Message-ID: <20170605.112909.1247890172910024411.davem@davemloft.net>
References: <3d006e19-8c96-a752-fbcb-bf8fc7ccb386@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch, f.fainelli@gmail.com
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38380 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdFEP3L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 11:29:11 -0400
In-Reply-To: <3d006e19-8c96-a752-fbcb-bf8fc7ccb386@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Sun, 4 Jun 2017 19:46:53 -0700

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix kernel-doc warnings (typo) in drivers/net/phy/phy.c:
> 
> ..//drivers/net/phy/phy.c:259: warning: No description found for parameter 'features'
> ..//drivers/net/phy/phy.c:259: warning: Excess function parameter 'feature' description in 'phy_lookup_setting'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
