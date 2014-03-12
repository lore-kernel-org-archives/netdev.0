From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ieee802154: at86rf230: add support for rf233
 chip
Date: Wed, 12 Mar 2014 00:06:04 -0400 (EDT)
Message-ID: <20140312.000604.2215858990248416668.davem@davemloft.net>
References: <1394497765-5288-1-git-send-email-stilwellt@openlabs.co>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: stilwellt@openlabs.co
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750737AbaCLEGG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Mar 2014 00:06:06 -0400
In-Reply-To: <1394497765-5288-1-git-send-email-stilwellt@openlabs.co>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Stilwell <stilwellt@openlabs.co>
Date: Mon, 10 Mar 2014 19:29:25 -0500

> The rf233 and rf231 are sufficiently similar that we can treat
> rf233 like rf231.
> 
> rf233 is missing some features that rf231 has, but we don't currently
> make use of them so there's nothing to handle differently yet.
> 
> Should we add support in the future for rf231 *_NOCLK or SLEEP states,
> or PAD_IO drive strength, exceptions will need to be made for rf233.
> 
> Signed-off-by: Thomas Stilwell <stilwellt@openlabs.co>

Applied, thank you.
