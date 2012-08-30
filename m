From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/7] net/fsl_pq_mdio: various small fixes
Date: Thu, 30 Aug 2012 13:30:48 -0400 (EDT)
Message-ID: <20120830.133048.974458618054446067.davem@davemloft.net>
References: <1346263683-3664-1-git-send-email-timur@freescale.com>
	<1346263683-3664-4-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: afleming@freescale.com, netdev@vger.kernel.org
To: timur@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38109 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230Ab2H3Rav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 13:30:51 -0400
In-Reply-To: <1346263683-3664-4-git-send-email-timur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@freescale.com>
Date: Wed, 29 Aug 2012 13:08:00 -0500

> 1) Replace printk with dev_err
> 
> 2) Fix some whitespace mistakes
> 
> 3) Rename "ofdev" to "pdev", since it's a platform_device now
> 
> 4) Fix an inadvertent compound statement by replacing commas with semicolons
> 
> Signed-off-by: Timur Tabi <timur@freescale.com>

Applied to net-next.
