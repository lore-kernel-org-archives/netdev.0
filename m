From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory corruption in 8390.c ?
Date: Thu, 22 Jun 2006 18:30:37 +1000
Message-ID: <20060622083037.GB26083@gondor.apana.org.au>
References: <1150909982.15275.100.camel@localhost.localdomain> <E1FtDU0-0005nd-00@gondolin.me.apana.org.au> <20060622023029.GA6156@gondor.apana.org.au> <20060622.012609.25474139.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alan@lxorguk.ukuu.org.uk, snakebyte@gmx.de,
	linux-kernel@vger.kernel.org, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:60164 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S964950AbWFVIax
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 04:30:53 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060622.012609.25474139.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 22, 2006 at 01:26:09AM -0700, David Miller wrote:
>
> Want me to let this cook in 2.6.18 for a while before sending
> it off to -stable?

You know I'm never one to push anything quickly so absolutely yes :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
