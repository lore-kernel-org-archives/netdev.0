From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] [IPSEC] IPV6: Fix to add tunnel mode SA correctly.
Date: Mon, 22 Oct 2007 16:37:20 +0800
Message-ID: <20071022083720.GA17865@gondor.apana.org.au>
References: <20071017.213523.58458049.davem@davemloft.net> <11930333741879-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4069 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751308AbXJVIhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 04:37:34 -0400
Content-Disposition: inline
In-Reply-To: <11930333741879-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 22, 2007 at 03:09:34PM +0900, Masahide NAKAMURA wrote:
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Thanks for catching my silly bug!

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
