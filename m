From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] sfc: Track RPS flow IDs per channel instead of
 per function
Date: Tue, 31 May 2016 20:30:36 -0700 (PDT)
Message-ID: <20160531.203036.863343374080101068.davem@davemloft.net>
References: <574DD410.1070209@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers@solarflare.com, netdev@vger.kernel.org
To: ecree@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756857AbcFADak (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2016 23:30:40 -0400
In-Reply-To: <574DD410.1070209@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Edward Cree <ecree@solarflare.com>
Date: Tue, 31 May 2016 19:12:32 +0100

> From: Jon Cooper <jcooper@solarflare.com>
> 
> Otherwise we get confused when two flows on different channels get the
>  same flow ID.
> 
> Signed-off-by: Edward Cree <ecree@solarflare.com>

Applied, thanks.
