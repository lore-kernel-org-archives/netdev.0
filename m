From: David Miller <davem@davemloft.net>
Subject: Re: Pull request: sfc 2013-02-26
Date: Tue, 26 Feb 2013 17:23:37 -0500 (EST)
Message-ID: <20130226.172337.962765205984206631.davem@davemloft.net>
References: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	scrum-linux@solarflare.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43228 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752482Ab3BZWXl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 17:23:41 -0500
In-Reply-To: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 26 Feb 2013 19:09:23 +0000

> The following changes since commit eb970ff07c15f13eb474f643fd165ebe3e4e24b2:
> 
>   usbnet: smsc95xx: rename FEATURE_AUTOSUSPEND (2013-02-25 15:49:52 -0500)
> 
> are available in the git repository at:
>   git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc.git sfc-3.9
> 
> Some fixes that should go into 3.9:
> 
> 1. Fix packet corruption when using non-coherent RX DMA buffers.
> 2. Fix occasional watchdog misfiring when changing MTU or ring size.
> 
> These are longstanding bugs and should be fixed in stable as well, but
> I'd like to review other recent fixes first and send a separate request
> for stable inclusion.

Pulled, thanks Ben.
