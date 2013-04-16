From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 v3] changed irq handling for at86rf230
Date: Tue, 16 Apr 2013 16:45:12 -0400 (EDT)
Message-ID: <20130416.164512.1538328416872607703.davem@davemloft.net>
References: <cover.1366012862.git.sascha@ps.nvbi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com
To: sascha@ps.nvbi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211Ab3DPUpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:45:15 -0400
In-Reply-To: <cover.1366012862.git.sascha@ps.nvbi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sascha Herrmann <sascha@ps.nvbi.de>
Date: Mon, 15 Apr 2013 10:33:27 +0200

> Changes to last version: Reordered local variable declarations.
> 
> The first patch add the option to configure the irq type of the
> plattform and the device. The second patch changes the irq handling
> when edge type interrupts are configured.
> 
> Without irq configuration of the irq type, the driver will remain
> backward compatible.

Series applied, thanks.
