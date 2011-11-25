From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: Remove obsolete source file
 'bond_ipv6.c'
Date: Fri, 25 Nov 2011 01:39:24 -0500 (EST)
Message-ID: <20111125.013924.150680363293401545.davem@davemloft.net>
References: <1322158581.2784.16.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51291 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751684Ab1KYGja (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2011 01:39:30 -0500
In-Reply-To: <1322158581.2784.16.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 24 Nov 2011 18:16:21 +0000

> This file is now unused and should have been removed by commit
> 7c89943236750537d26421d9bbb6f6575e2d1e1b ("bonding, ipv4, ipv6, vlan:
> Handle NETDEV_BONDING_FAILOVER like NETDEV_NOTIFY_PEERS").
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks.
