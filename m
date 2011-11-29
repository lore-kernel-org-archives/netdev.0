From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: optimize socket timestamping
Date: Tue, 29 Nov 2011 01:22:31 -0500 (EST)
Message-ID: <20111129.012231.1179552654543190543.davem@davemloft.net>
References: <1322517858.2970.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751316Ab1K2GWf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 01:22:35 -0500
In-Reply-To: <1322517858.2970.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 28 Nov 2011 23:04:18 +0100

> We can test/set multiple bits from sk_flags at once, to shorten a bit
> socket setup/dismantle phase.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
