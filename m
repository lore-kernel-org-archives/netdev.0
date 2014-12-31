From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/3] net: fec: add Wake-on-LAN support
Date: Wed, 31 Dec 2014 13:07:27 -0500 (EST)
Message-ID: <20141231.130727.1660985956287926494.davem@davemloft.net>
References: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawn.guo@linaro.org, netdev@vger.kernel.org,
	bhutchings@solarflare.com, stephen@networkplumber.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44593 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750760AbaLaSHd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2014 13:07:33 -0500
In-Reply-To: <1419413441-3406-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 24 Dec 2014 17:30:38 +0800

> The patch series enable FEC Wake-on-LAN feature for i.MX6q/dl and i.MX6SX SOCs.
> FEC HW support sleep mode, when system in suspend status with FEC all clock gate
> off, magic packet can wake up system. For different SOCs, there have special SOC
> GPR register to let FEC enter sleep mode or exit sleep mode, add these to platform
> callback for driver' call.
> 
> Patch#1: add WOL interface supports.
> Patch#2: add SOC special sleep of/off operations for driver's sleep callback.
> Patch#3: add magic pattern support for devicetree.

Series applied, thanks.
