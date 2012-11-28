From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gro: Handle inline VLAN tags
Date: Wed, 28 Nov 2012 13:39:31 -0500 (EST)
Message-ID: <20121128.133931.1920292698414428662.davem@davemloft.net>
References: <50B3850C.4070902@myri.com>
	<20121128.114602.1208211617672057364.davem@davemloft.net>
	<50B64A24.60200@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	herbert@gondor.hengli.com.au
To: gallatin@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51532 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755536Ab2K1Sjg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:39:36 -0500
In-Reply-To: <50B64A24.60200@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Gallatin <gallatin@myri.com>
Date: Wed, 28 Nov 2012 12:30:12 -0500

> Perfect, thanks.  Eric seemed OK with doing the vlan decap
> in the driver.  But.. I didn't get an "nack" or an "applied" from
> you in response to that myri10ge patchset.  Do I need to re-submit it?
> 
> Sorry, I'm not terribly familiar with the etiquette for this sort
> of thing.

Please just repost the patch set.
