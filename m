From: David Miller <davem@davemloft.net>
Subject: Re: [v2 PATCH 0/6] rhashtable: Fixes + cleanups + preparation for
 multiple rehash
Date: Sun, 15 Mar 2015 01:36:13 -0400 (EDT)
Message-ID: <20150315.013613.2034532005621627761.davem@davemloft.net>
References: <20150313095607.GA598@gondor.apana.org.au>
	<20150314025339.GA10585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38799 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbbCOFgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 01:36:17 -0400
In-Reply-To: <20150314025339.GA10585@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 14 Mar 2015 13:53:39 +1100

> Patch 1 fixes the walker so that it behaves properly even during
> a resize.
> 
> Patch 2-3 are cleanups.
> 
> Patch 4-6 lays some ground work for the upcoming multiple rehashing.
> 
> This revision fixes the warning coming from the bucket_table->size
> downsize and improves its changelog.

Series applied, thanks a lot Herbert.
