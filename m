From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] fix IPv6 queries for bridge multicast snooping
Date: Wed, 15 Dec 2010 09:00:50 +0800
Message-ID: <20101215010050.GB20448@gondor.apana.org.au>
References: <1292352136.4720.11.camel@IBM-1B506CFC885>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.org, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40980 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760325Ab0LOBA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Dec 2010 20:00:57 -0500
Content-Disposition: inline
In-Reply-To: <1292352136.4720.11.camel@IBM-1B506CFC885>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 14, 2010 at 10:42:16AM -0800, David L Stevens wrote:
> This patch fixes a missing ntohs() for bridge IPv6 multicast snooping.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

I had wanted to fix this but forgot :)

Thanks,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
