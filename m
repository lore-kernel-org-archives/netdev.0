From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV4]: Uninline netfilter okfns
Date: Mon, 15 Oct 2007 16:05:46 +0800
Message-ID: <20071015080546.GB29580@gondor.apana.org.au>
References: <E1IbT8r-0000Av-00@gondolin.me.apana.org.au> <46FE6D73.4000002@trash.net> <20070929.171339.59681016.davem@davemloft.net> <20070930002601.GB7502@gondor.apana.org.au> <20070930004341.GA7769@gondor.apana.org.au> <46FFC2F4.8090602@trash.net> <20071014042604.GA11431@gondor.apana.org.au> <47131D64.3080008@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2231 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751333AbXJOIXX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 04:23:23 -0400
Content-Disposition: inline
In-Reply-To: <47131D64.3080008@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 15, 2007 at 09:57:24AM +0200, Patrick McHardy wrote:
>
> Before:
>    text    data     bss     dec     hex filename
> 8997385 1016524  524652 10538561         a0ce41 vmlinux
> 
> After:
>    text    data     bss     dec     hex filename
> 8994009 1016524  524652 10535185         a0c111 vmlinux
> -------------------------------------------------------
>   -3376

Nice work Patrick :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
