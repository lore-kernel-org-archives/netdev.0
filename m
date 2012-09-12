From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] Generalise "auto-negotiation done" function, move
 generic PHY code to phy_device.c
Date: Wed, 12 Sep 2012 14:05:22 -0400 (EDT)
Message-ID: <20120912.140522.912336194714928072.davem@davemloft.net>
References: <50506DCE.9050400@sysgo.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, afleming@freescale.com
To: asv@sysgo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32851 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753508Ab2ILSFZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 14:05:25 -0400
In-Reply-To: <50506DCE.9050400@sysgo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please set your Subject lines correctly.

It should be:

[PATCH VX] $(subsystem): $(description)

Without the subsystem prefix people can't tell quickly what general
area of code you are changing.

For these changes I'd use either "net: " or "phy: " as the subsystem
prefix.
