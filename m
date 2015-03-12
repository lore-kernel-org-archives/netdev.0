From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4 v2] rhashtable hash cleanups
Date: Thu, 12 Mar 2015 14:36:11 -0400 (EDT)
Message-ID: <20150312.143611.1943593719035919241.davem@davemloft.net>
References: <20150312012944.GA12857@gondor.apana.org.au>
	<20150312034923.GA14415@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38407 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751812AbbCLSgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 14:36:14 -0400
In-Reply-To: <20150312034923.GA14415@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 12 Mar 2015 14:49:23 +1100

> This is a rebase on top of the nested lock annotation fix.
> 
> Nothing to see here, just a bunch of simple clean-ups before
> I move onto something more substantial (hopefully).

I've applied this series, but please look into the bug Thomas
reported before making any further changes to rhashtable.

Thanks.
