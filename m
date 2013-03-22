From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] decnet: Move rtm_dn_policy to dn_route to
 make it available if !CONFIG_DECNET_ROUTER
Date: Fri, 22 Mar 2013 12:52:28 -0400 (EDT)
Message-ID: <20130322.125228.730833465331933042.davem@davemloft.net>
References: <20130322142735.GA11368@casper.infradead.org>
	<20130322.103135.962113441677649820.davem@davemloft.net>
	<20130322165029.GB19293@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51613 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1160998Ab3CVQwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Mar 2013 12:52:30 -0400
In-Reply-To: <20130322165029.GB19293@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Fri, 22 Mar 2013 16:50:29 +0000

> Otherwise build fails with CONFIG_DECNET && !CONFIG_DECNET_ROUTER
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Thomas Graf <tgraf@suug.ch>

Applied, thanks Thomas.
