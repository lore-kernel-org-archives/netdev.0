From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] mlx4_en: Adding BQL support
Date: Mon, 23 Apr 2012 22:34:16 -0400 (EDT)
Message-ID: <20120423.223416.953451389550267595.davem@davemloft.net>
References: <4F954893.3040401@mellanox.co.il>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34528 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756259Ab2DXCeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:34:23 -0400
In-Reply-To: <4F954893.3040401@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Mon, 23 Apr 2012 15:18:27 +0300

> This patchset adds Byte Queue Limit support to the mlx4_en driver.
> As a precondition to this I had to change the mode of TX completion handling
> Till now we have handled completions by polling from the xmit context,
> once in every 16 packets.
> Now moving to interrupts, and also added the set/get coalescing option for TX interrupts.

All applied to net-next, thanks.
