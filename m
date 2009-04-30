From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] myr10ge: again fix lro_gen_skb() alignment
Date: Thu, 30 Apr 2009 16:14:04 +0800
Message-ID: <20090430081404.GA28230@gondor.apana.org.au>
References: <20090428061225.GA1591@gondor.apana.org.au> <49F71A00.5090701@myri.com> <20090428152047.GB7549@gondor.apana.org.au> <49F77134.9030907@myri.com> <49F85945.7030900@myri.com> <49F85BF1.1020501@cosmosbay.com> <49F861BF.7060403@myri.com> <49F87188.9000904@cosmosbay.com> <49F88E5A.8070908@myri.com> <20090430081051.GA28133@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>, brice@myri.com,
	sgruszka@redhat.com, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:45203 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751329AbZD3ION (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 04:14:13 -0400
Content-Disposition: inline
In-Reply-To: <20090430081051.GA28133@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 04:10:51PM +0800, Herbert Xu wrote:
>
> So I won't be able to test this until I locate another myri10ge
> card or get this one back up and running again.

Another reboot seems to have fixed it.  So all is good.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
