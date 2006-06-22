From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 21:29:36 +1000
Message-ID: <E1FtNNQ-0001QW-00@gondolin.me.apana.org.au>
References: <1150976063.15275.146.camel@localhost.localdomain>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57608 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1161073AbWFVL35
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 07:29:57 -0400
To: alan@lxorguk.ukuu.org.uk (Alan Cox)
In-Reply-To: <1150976063.15275.146.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:
> 
> The 8390 change (corrected version) also makes 8390.c faster so should
> be applied anyway, and the orinoco one fixes some code that isn't even
> needed and someone forgot to remove long ago. Otherwise the skb_padto

Yeah I agree totally.  However, I haven't actually seen the fixed 8390
version being posted yet or at least not to netdev :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
