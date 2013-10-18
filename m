From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: Delete trailing semi-colon from
 definition of netdev_WARN()
Date: Fri, 18 Oct 2013 00:13:37 -0400 (EDT)
Message-ID: <20131018.001337.306511939810757516.davem@davemloft.net>
References: <1381783761.1626.16.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50336 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841Ab3JRENj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 00:13:39 -0400
In-Reply-To: <1381783761.1626.16.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Mon, 14 Oct 2013 21:49:21 +0100

> Macro definitions should not normally end with a semi-colon, as this
> makes it dangerous to use them an if...else statement.  Happily this
> has not happened yet.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
