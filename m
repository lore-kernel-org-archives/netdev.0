From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tun: Turn tun_flow_init() into void fn
Date: Wed, 12 Jun 2013 15:09:17 -0700 (PDT)
Message-ID: <20130612.150917.750186314300995907.davem@davemloft.net>
References: <51B71F94.6020507@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60895 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756858Ab3FLWJS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 18:09:18 -0400
In-Reply-To: <51B71F94.6020507@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Tue, 11 Jun 2013 17:01:08 +0400

> This routine doesn't fail since 9fdc6bef (tuntap: dont use a private kmem_cache)
> so it makes sense to compact the code a little bit.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

Applied.
