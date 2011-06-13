From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3 00/10] net: expand time stamping, batch #1
Date: Mon, 13 Jun 2011 17:26:50 -0400 (EDT)
Message-ID: <20110613.172650.482765433985419839.davem@davemloft.net>
References: <cover.1307880494.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50760 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753730Ab1FMV0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2011 17:26:54 -0400
In-Reply-To: <cover.1307880494.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sun, 12 Jun 2011 14:18:57 +0200

> Richard Cochran (10):
>   net: export time stamp utility function for Ethernet MAC drivers
>   fec: enable transmit and receive time stamping.
>   davinci_emac: pass ioctls through to phy device.
>   davinci_emac: enable transmit time stamping.
>   tg3: enable transmit time stamping.
>   dnet: enable transmit time stamping.
>   ethoc: enable transmit time stamping.
>   r6040: enable transmit time stamping.
>   stmmac: enable transmit time stamping.
>   smsc9420: enable transmit time stamping.

All applied to net-next-2.6, thanks.
