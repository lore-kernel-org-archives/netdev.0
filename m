From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] net: introduce NAPI_POLL_WEIGHT
Date: Tue, 05 Mar 2013 23:59:17 -0500 (EST)
Message-ID: <20130305.235917.920355614898666298.davem@davemloft.net>
References: <1362535042.15793.144.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60885 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671Ab3CFE7S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:59:18 -0500
In-Reply-To: <1362535042.15793.144.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Mar 2013 17:57:22 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Some drivers use a too big NAPI poll weight.
> 
> This patch adds a NAPI_POLL_WEIGHT default value
> and issues an error message if a driver attempts
> to use a bigger weight.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Eilon Greenstein <eilong@broadcom.com>

Applied.
