From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] rhashtable: Simplify iterator code
Date: Tue, 05 May 2015 19:30:58 -0400 (EDT)
Message-ID: <20150505.193058.2304773069683051018.davem@davemloft.net>
References: <40f6c87a0abb31ca17cb6299660ce3acd38da33c.1430785277.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: tgraf@suug.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57947 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754699AbbEEXbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:31:00 -0400
In-Reply-To: <40f6c87a0abb31ca17cb6299660ce3acd38da33c.1430785277.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Graf <tgraf@suug.ch>
Date: Tue,  5 May 2015 02:22:53 +0200

> Remove useless obj variable and goto logic.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied.
