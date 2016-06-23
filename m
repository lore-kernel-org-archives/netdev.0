From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: esp: Fix ESN generation under UDP encapsulation
Date: Thu, 23 Jun 2016 12:40:07 +0200
Message-ID: <20160623104007.GO7698@gauss.secunet.com>
References: <20160612234814.15460-1-blair.steven@alliedtelesis.co.nz>
 <20160613102024.GX7698@gauss.secunet.com>
 <5760A501.3070504@alliedtelesis.co.nz>
 <20160617102429.GH7698@gauss.secunet.com>
 <20160618050336.GA12205@gondor.apana.org.au>
 <20160620105934.GL7698@gauss.secunet.com>
 <576B64B1.9030000@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Blair Steven <Blair.Steven@alliedtelesis.co.nz>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36163 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbcFWKkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 06:40:13 -0400
Content-Disposition: inline
In-Reply-To: <576B64B1.9030000@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 23, 2016 at 04:25:21AM +0000, Blair Steven wrote:
> This change tests okay in my setup.
> 
> Thanks very much
> -Blair

David, can you please take this patch directly in the net tree?
This is a candidate for stable.

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
