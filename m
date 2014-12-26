From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: xilinx: Remove unnecessary temac_property in the
 driver
Date: Fri, 26 Dec 2014 17:06:34 -0500 (EST)
Message-ID: <20141226.170634.1467105628556822771.davem@davemloft.net>
References: <072fa5b149374b09b3f6d5d767714d3e@BN1AFFO11FD010.protection.gbl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anirudh@xilinx.com, John.Linn@xilinx.com, michal.simek@xilinx.com,
	soren.brinkmann@xilinx.com, grant.likely@linaro.org,
	robh+dt@kernel.org, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org, appanad@xilinx.com
To: appana.durga.rao@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40789 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbaLZWHD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2014 17:07:03 -0500
In-Reply-To: <072fa5b149374b09b3f6d5d767714d3e@BN1AFFO11FD010.protection.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kedareswara rao Appana <appana.durga.rao@xilinx.com>
Date: Tue, 23 Dec 2014 18:07:55 +0530

> This property is no longer used in the code yet the code looks for it in the device tree.
> It does not cause an error if it's not in the tree.
> 
> Signed-off-by: Kedareswara rao Appana <appanad@xilinx.com>

Applied, thanks.
