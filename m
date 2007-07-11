From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Update comments for skb checksums
Date: Tue, 10 Jul 2007 22:42:12 -0700 (PDT)
Message-ID: <20070710.224212.18577949.davem@davemloft.net>
References: <20070711013353.GA6082@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rusty@rustcorp.com.au
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44377
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754587AbXGKFlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 01:41:50 -0400
In-Reply-To: <20070711013353.GA6082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 11 Jul 2007 09:33:53 +0800

> Hi Dave:
> 
> [NET]: Update comments for skb checksums
> 
> Rusty (whose comments we should all study and emulate :) pointed
> out that our comments for skb checksums are no longer up-to-date.
> So here is a patch to
> 
> 1) add the case of partial checksums on input;
> 2) update partial checksum case to mention csum_start/csum_offset;
> 3) mention the new IPv6 feature bit.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks Herbert.
