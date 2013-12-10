From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: emaclite: Remove unnecessary code that
 enables/disables interrupts on PONG buffers
Date: Mon, 09 Dec 2013 21:02:41 -0500 (EST)
Message-ID: <20131209.210241.1312012384456187129.davem@davemloft.net>
References: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	michal.simek@xilinx.com
To: sthokal@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751048Ab3LJCCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Dec 2013 21:02:42 -0500
In-Reply-To: <1386403849-3153-1-git-send-email-sthokal@xilinx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Srikanth Thokala <sthokal@xilinx.com>
Date: Sat,  7 Dec 2013 13:40:48 +0530

> There are no specific interrupts for the PONG buffer on both
> transmit and receive side, same interrupt is valid for both
> buffers. So, this patch removes this code.
> 
> Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
> Reviewed-by: Michal Simek <monstr@monstr.eu>

Applied.
