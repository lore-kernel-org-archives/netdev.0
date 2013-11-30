From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net/hsr: Fix omissions
Date: Sat, 30 Nov 2013 12:49:16 -0500 (EST)
Message-ID: <20131130.124916.886794226134774421.davem@davemloft.net>
References: <52991680.1020707@alten.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, joe@perches.com,
	jboticario@gmail.com, balferreira@googlemail.com,
	elias.molina@ehu.es
To: arvid.brodin@alten.se
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751627Ab3K3RtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 12:49:18 -0500
In-Reply-To: <52991680.1020707@alten.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arvid Brodin <arvid.brodin@alten.se>
Date: Fri, 29 Nov 2013 23:34:40 +0100

> This is a patch series that fixes a few omissions in the original HSR patch.
> 
> The HSR driver is completely new in v3.13-rc1, so the risk that someone would
> hit a regression should be very small. Also, the HSR driver is pretty useless
> without iproute support, which depends on patch 3 in the series. So I hope 
> these are OK for net.

Series applied.
