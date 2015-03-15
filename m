From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 0/6] rhashtable: Fix two bugs caused by multiple
 rehash preparation
Date: Sun, 15 Mar 2015 21:43:48 +1100
Message-ID: <20150315104348.GB21999@gondor.apana.org.au>
References: <20150313095607.GA598@gondor.apana.org.au>
 <20150314025339.GA10585@gondor.apana.org.au>
 <20150315.013613.2034532005621627761.davem@davemloft.net>
 <20150315101004.GA21383@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:40176 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751721AbbCOKnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Mar 2015 06:43:52 -0400
Content-Disposition: inline
In-Reply-To: <20150315101004.GA21383@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2015 at 09:10:04PM +1100, Herbert Xu wrote:
> Hi Dave:
> 
> While testing some new patches over the weekend I discovered a
> couple of bugs in the series that had just been merged.  These
> two patches fix them:

Doh, obviously the subject should have said 0/2, not 0/6.
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
