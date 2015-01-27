From: David Miller <davem@davemloft.net>
Subject: Re: netlink: Kill redundant net argument in netlink_insert
Date: Tue, 27 Jan 2015 00:30:58 -0800 (PST)
Message-ID: <20150127.003058.2155008113648861179.davem@davemloft.net>
References: <20150126030256.GA20066@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48445 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752752AbbA0Ia7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 03:30:59 -0500
In-Reply-To: <20150126030256.GA20066@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 26 Jan 2015 14:02:56 +1100

> The socket already carries the net namespace with it so there is
> no need to be passing another net around.
>     
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-next, thanks Herbert.
