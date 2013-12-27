From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tile_net: Always enable PTP clock support on TILE-Gx
Date: Fri, 27 Dec 2013 12:45:11 -0500 (EST)
Message-ID: <20131227.124511.1712801659294116790.davem@davemloft.net>
References: <1387480874.1876.33.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cmetcalf@tilera.com, richardcochran@gmail.com,
	netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59877 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753923Ab3L0RpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 12:45:12 -0500
In-Reply-To: <1387480874.1876.33.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 19 Dec 2013 19:21:14 +0000

> All other net drivers with PTP support enable it unconditionally.
> Make tile_net consistent with this.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Totally untested as I don't have even a compiler for this.

Applied to net-next, thanks.
