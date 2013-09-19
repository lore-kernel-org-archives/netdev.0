From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phy/micrel: Add suspend/resume support to Micrel PHYs
Date: Thu, 19 Sep 2013 14:08:29 -0400 (EDT)
Message-ID: <20130919.140829.372011462903870193.davem@davemloft.net>
References: <1379612448-20805-1-git-send-email-nicolas.ferre@atmel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, b.brezillon@overkiz.com,
	f.fainelli@gmail.com, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, patrice.vilchez@atmel.com,
	david.choi@micrel.com
To: nicolas.ferre@atmel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379612448-20805-1-git-send-email-nicolas.ferre@atmel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 19 Sep 2013 19:40:48 +0200

> From: Patrice Vilchez <patrice.vilchez@atmel.com>
> 
> All supported Micrel PHYs implement the standard "power down" bit 11 of BMCR,
> so this patch adds support using the generic genphy_{suspend,resume} functions.
> 
> Signed-off-by: Patrice Vilchez <patrice.vilchez@atmel.com>
> [b.brezillon@overkiz.com: adapt to newer kernel and generalize to other phys]
> Signed-off-by: Boris BREZILLON <b.brezillon@overkiz.com>
> [nicolas.ferre@atmel.com: commit message modification]
> Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
> Cc: David J. Choi <david.choi@micrel.com>

What's the difference between this patch and the one you sent 60
seconds beforehand?
