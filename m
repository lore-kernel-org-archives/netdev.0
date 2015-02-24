From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: via-rhine: add BQL support
Date: Tue, 24 Feb 2015 16:30:22 -0500 (EST)
Message-ID: <20150224.163022.1493427067271976950.davem@davemloft.net>
References: <CAPAfteyiuPg2NAsggYp_mPRRAGoWAp4ut76zLhEVnkoABK7t6w@mail.gmail.com>
	<1424312906.4942.115.camel@edumazet-glaptop2.roam.corp.google.com>
	<1424802481.5565.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: milky-kernel@mcmilk.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51224 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752339AbbBXVaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 16:30:25 -0500
In-Reply-To: <1424802481.5565.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Feb 2015 10:28:01 -0800

> From: Tino Reichardt <milky-kernel@mcmilk.de>
> 
> Add Byte Queue Limits (BQL) support to via-rhine driver.
> 
> [edumazet] tweaked patch and changed TX_RING_SIZE from 16 to 64
> 
> Signed-off-by: Tino Reichardt <milky-kernel@mcmilk.de>
> Tested-by: Jamie Gloudon <jamie.gloudon@gmail.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Looks good, applied, thanks.
