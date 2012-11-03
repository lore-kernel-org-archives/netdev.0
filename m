From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sfc: Select PTP_1588_CLOCK
Date: Fri, 02 Nov 2012 21:31:23 -0400 (EDT)
Message-ID: <20121102.213123.61361565598342676.davem@davemloft.net>
References: <1351804942.2883.47.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49267 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755797Ab2KCBbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2012 21:31:24 -0400
In-Reply-To: <1351804942.2883.47.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 1 Nov 2012 21:22:22 +0000

> This was missed in commit a24006ed12616bde1bbdb26868495906a212d8dc
> ('ptp: Enable clock drivers along with associated net/PHY drivers')
> which enabled sfc's clock driver unconditionally.
> 
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Applied, thanks Ben.
