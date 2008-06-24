From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: pppoe: fix compiler warning
Date: Wed, 25 Jun 2008 00:12:50 +0800
Message-ID: <20080624161250.GB11124@gondor.apana.org.au>
References: <48611A06.9070607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57978 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753271AbYFXQM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jun 2008 12:12:59 -0400
Content-Disposition: inline
In-Reply-To: <48611A06.9070607@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 24, 2008 at 06:00:06PM +0200, Patrick McHardy wrote:

> pppoe: fix compiler warning
> 
> Fix warning introduced by 392fdb0 (net pppoe: Check packet length on all receive paths):
> 
> drivers/net/pppoe.c: In function 'pppoe_recvmsg':
> drivers/net/pppoe.c:945: warning: comparison of distinct pointer types lacks a cast
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks Patrick!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
