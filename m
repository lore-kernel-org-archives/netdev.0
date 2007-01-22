From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] tcp_output: Re: rare bad TCP checksum with 2.6.19?
Date: Mon, 22 Jan 2007 18:45:57 +1100
Message-ID: <20070122074557.GA15461@gondor.apana.org.au>
References: <45AE2EDF.4060709@tls.msk.ru> <20070119110641.GA3135@ff.dom.local> <20070119211027.GA16626@gondor.apana.org.au> <20070122065214.GA1634@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4642 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751854AbXAVHqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jan 2007 02:46:19 -0500
To: Jarek Poplawski <jarkao2@o2.pl>
Content-Disposition: inline
In-Reply-To: <20070122065214.GA1634@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jan 22, 2007 at 07:52:14AM +0100, Jarek Poplawski wrote:
>  
> I was so impressed by the amount of work done by Michael
> that I magnified his merit and forgot to mention the role
> of Patrick and Herbert, particularly here:

You don't need to be so modest!

While no doubt Patrick helped in tracking this down, my role in
this thread is solely in adding this bug in the first place :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
