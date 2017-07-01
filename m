From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arm: sunxi: Revert changes merged through net-next.
Date: Sat, 01 Jul 2017 14:18:31 -0700 (PDT)
Message-ID: <20170701.141831.777812052121454399.davem@davemloft.net>
References: <20170630074617.20288-1-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wens@csie.org, clabbe.montjoie@gmail.com, netdev@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org
To: maxime.ripard@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33996 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752119AbdGAVSd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 17:18:33 -0400
In-Reply-To: <20170630074617.20288-1-maxime.ripard@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Fri, 30 Jun 2017 09:46:17 +0200

> This reverts commits 2c0cba482e79 ("arm: sun8i: sunxi-h3-h5: Add dt node
> for the syscon control module") to 2428fd0fe550 ("arm64: defconfig: Enable
> dwmac-sun8i driver on defconfig") and 3432a86e641c ("arm: sun8i:
> orangepipc: use internal phy-mode") to 5a79b4f2a5e7 ("arm: sun8i:
> orangepi-2: use internal phy-mode") that should be merged
> through the arm-soc tree, and end up in merge conflicts and build failures.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied to net-next, thanks.
