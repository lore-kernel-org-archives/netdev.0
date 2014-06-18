From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Added FS A8NE-FM to the list of 32bit DMA
 boards
Date: Wed, 18 Jun 2014 16:47:32 -0700 (PDT)
Message-ID: <20140618.164732.265431469345479600.davem@davemloft.net>
References: <53A01E33.7000905@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mlindner@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36231 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756218AbaFRXrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 19:47:33 -0400
In-Reply-To: <53A01E33.7000905@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mirko Lindner <mlindner@marvell.com>
Date: Tue, 17 Jun 2014 12:53:39 +0200

> Added FUJITSU SIEMENS A8NE-FM to the list of 32bit DMA boards
> 
> From Tomi O.:
> After I added an entry to this MB into the skge.c
> driver in order to enable the mentioned 64bit dma disable quirk,
> the network data corruptions ended and everything is fine again.
> 
> Signed-off-by: Mirko Lindner <mlindner@marvell.com>

Applied, but please use an appropriate subsystem prefix in
your subject lines, this should have been something like:

[PATCH net-next] skge: Added FS A8NE-FM ...
