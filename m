From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [v1 PATCH 7/7] rhashtable: Rip out obsolete out-of-line interface
Date: Sat, 21 Mar 2015 08:24:44 +1100
Message-ID: <20150320212444.GB23301@gondor.apana.org.au>
References: <20150320105421.GA18148@gondor.apana.org.au>
 <E1YYuby-0004mT-AN@gondolin.me.apana.org.au>
 <20150320202516.GA27511@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([178.18.16.133]:57622 "EHLO
	ringil.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751129AbbCTVYz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 17:24:55 -0400
Content-Disposition: inline
In-Reply-To: <20150320202516.GA27511@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 20, 2015 at 08:25:16PM +0000, Thomas Graf wrote:
> 
> Any reason to keep the _fast() suffix if we only keep the inline
> variants anyway?

Feel free to kill the _fast suffix.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
