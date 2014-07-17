From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] sfc: Add per-queue statistics in ethtool
Date: Thu, 17 Jul 2014 16:49:01 -0700 (PDT)
Message-ID: <20140717.164901.1967183695888196576.davem@davemloft.net>
References: <53C7AF33.5000109@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41589 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758565AbaGQXtC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 19:49:02 -0400
In-Reply-To: <53C7AF33.5000109@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Thu, 17 Jul 2014 12:10:43 +0100

> From: Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>
> 
> Implement per channel software TX and RX packet counters
> accessed as ethtool statistics.
> 
> This allows confirmation with MAC statistics.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied.
