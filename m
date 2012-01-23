From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mv643xx_eth: Add Rx Discard and Rx Overrun statistics
Date: Mon, 23 Jan 2012 14:01:11 -0500 (EST)
Message-ID: <20120123.140111.1053797193047563823.davem@davemloft.net>
References: <20120123111635.15315.64174.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, netdev@vger.kernel.org
To: paulius.zaleckas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57464 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750824Ab2AWTBO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2012 14:01:14 -0500
In-Reply-To: <20120123111635.15315.64174.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paulius Zaleckas <paulius.zaleckas@gmail.com>
Date: Mon, 23 Jan 2012 13:16:35 +0200

> These statistics helped me a lot while searching who is losing
> packets in my setup.
> I added these stats to MIB group since they are very similar,
> but just in other registers.
> I have tested this patch on 88F6281 SoC.
> 
> Signed-off-by: Paulius Zaleckas <paulius.zaleckas@gmail.com>

Applied, thanks.
