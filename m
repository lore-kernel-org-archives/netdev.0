From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH net-next v2] rhashtable: Warn if min_size or max_size are
 not a power of two
Date: Fri, 20 Mar 2015 09:02:48 +1100
Message-ID: <20150319220248.GA12428@gondor.apana.org.au>
References: <29119e13cd16d4a98b4ed6806bec2683943bcd5f.1426782799.git.tgraf@suug.ch>
 <20150319.152450.1573636653085091157.davem@davemloft.net>
 <20150319194608.GA27962@casper.infradead.org>
 <20150319210239.GB9601@gondor.apana.org.au>
 <20150319211546.GA4190@casper.infradead.org>
 <20150319214933.GA11937@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:36835 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751148AbbCSWCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 18:02:54 -0400
Content-Disposition: inline
In-Reply-To: <20150319214933.GA11937@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 08:49:33AM +1100, Herbert Xu wrote:
>
> OK let's fix the test then.  The easiest way would be to round
> max_size up to the next power of 2.

s/up/down/
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
