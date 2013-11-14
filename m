From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/6] net_tstamp: Validate hwtstamp_config
 completely before applying it
Date: Thu, 14 Nov 2013 01:53:49 -0500 (EST)
Message-ID: <20131114.015349.1807324350138019956.davem@davemloft.net>
References: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47976 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049Ab3KNGxv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 01:53:51 -0500
In-Reply-To: <1384389542.29151.5.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 14 Nov 2013 00:39:02 +0000

> This series fixes very similar bugs in 6 implementations of
> SIOCSHWTSTAMP.

This looks fine to me, I'll just way a day or so for driver maintainers
to ACK.
