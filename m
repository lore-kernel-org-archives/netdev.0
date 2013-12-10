From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] net: emaclite: add barriers to support Xilinx
 Zynq platform
Date: Mon, 09 Dec 2013 21:02:45 -0500 (EST)
Message-ID: <20131209.210245.1701870982898263902.davem@davemloft.net>
References: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
	<1386403849-3153-2-git-send-email-sthokal@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	michal.simek@xilinx.com
To: sthokal@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751133Ab3LJCCr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:02:47 -0500
In-Reply-To: <1386403849-3153-2-git-send-email-sthokal@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srikanth Thokala <sthokal@xilinx.com>
Date: Sat,  7 Dec 2013 13:40:49 +0530

> This patch adds barriers at appropriate places to ensure the driver
> works on Xilinx Zynq ARM-based SoC platform.
> 
> Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>

Applied.
