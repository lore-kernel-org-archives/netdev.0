From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] sfc: only use vadaptor stats if firmware is
 capable
Date: Thu, 27 Aug 2015 11:27:24 -0700 (PDT)
Message-ID: <20150827.112724.2053504429646294443.davem@davemloft.net>
References: <55DDDD97.90204@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45557 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750945AbbH0S1Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 14:27:25 -0400
In-Reply-To: <55DDDD97.90204@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 26 Aug 2015 16:39:03 +0100

> From: Bert Kenward <bkenward@solarflare.com>
> 
> Some of the stats handling code differs based on SR-IOV support,
> and SRIOV support is only available if full-featured firmware is
> used.
> Do not use vadaptor stats if firmware mode is not set to
> full-featured.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied, thank you.
