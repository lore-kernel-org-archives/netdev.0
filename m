From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-10-08
Date: Tue, 08 Oct 2013 21:56:26 -0400 (EDT)
Message-ID: <20131008.215626.333377123257954825.davem@davemloft.net>
References: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753378Ab3JIB41 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 21:56:27 -0400
In-Reply-To: <1381254091.1530.9.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 8 Oct 2013 18:41:31 +0100

> Some more fixes for EF10 support; hopefully the last lot:
> 
> 1. Fixes for reading statistics, from Edward Cree and Jon Cooper.
> 2. Addition of ethtool statistics for packets dropped by the hardware
> before they were associated with a specific function, from Edward Cree.
> 3. Only bind to functions that are in control of their associated port,
> as the driver currently assumes this is the case.

Pulled, thanks Ben.
