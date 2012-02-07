From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Revert "skge: check for PCI dma mapping errors"
Date: Tue, 07 Feb 2012 12:51:27 -0500 (EST)
Message-ID: <20120207.125127.2019091021258740694.davem@davemloft.net>
References: <20120127091831.49ba7e68@nehalam.linuxnetplumber.net>
	<1327688328.8784.2.camel@penelope>
	<20120206170423.77492bb5@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: prahal@yahoo.com, netdev@vger.kernel.org, guichaz@gmail.com,
	nbowler@elliptictech.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35065 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753195Ab2BGRvf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 12:51:35 -0500
In-Reply-To: <20120206170423.77492bb5@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 6 Feb 2012 17:04:23 -0800

> As reported by several people...
> 
> The code in rx_clean was panic'ing so revert 
> commit d0249e44432aa0ffcf710b64449b8eaa3722547e.
> Will redo DMA mapping checks as new patches for a later release.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks.
