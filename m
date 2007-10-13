From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Sat, 13 Oct 2007 20:49:56 +0800
Message-ID: <E1IggRI-0001Zc-00@gondolin.me.apana.org.au>
References: <20071013144300.08128901@hyperion.delvare>
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: khali@linux-fr.org (Jean Delvare)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2299 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751631AbXJMMug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Oct 2007 08:50:36 -0400
In-Reply-To: <20071013144300.08128901@hyperion.delvare>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jean Delvare <khali@linux-fr.org> wrote:
>
> I didn't know that, sorry. What is the new interface to access the
> TCP information?

inet_diag is the preferred interface.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
