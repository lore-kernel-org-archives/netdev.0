From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next] drivers/net/ks*: Use netdev_<level>,
 netif_<level> and pr_<level>
Date: Tue, 16 Mar 2010 21:31:33 -0700 (PDT)
Message-ID: <20100316.213133.102673436.davem@davemloft.net>
References: <1267317831.30706.26.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Tristram.Ha@micrel.com, ben@simtec.co.uk, david.choi@micrel.com,
	richard.rojfors.ext@mocean-labs.com, netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51601
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752720Ab0CQEbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Mar 2010 00:31:11 -0400
In-Reply-To: <1267317831.30706.26.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 27 Feb 2010 16:43:51 -0800

> I'm not sure this is correct.
> 
> It changes logging macros from:
> 	dev_<level>(&ks->spidev->dev,
> to
> 	netdev_<level>(ks->netdev,

I'm just applying this, more than a week to get a review
is more than enough.

Thanks Joe.
