From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 21:11:57 +0800
Message-ID: <20110301131157.GA8028@gondor.apana.org.au>
References: <1298912869.2941.687.camel@edumazet-laptop> <20110301101955.GI9763@canuck.infradead.org> <1298975602.3284.13.camel@edumazet-laptop> <20110301110708.GJ9763@canuck.infradead.org> <1298977984.3284.15.camel@edumazet-laptop> <20110301112759.GK9763@canuck.infradead.org> <1298979909.3284.28.camel@edumazet-laptop> <20110301115305.GA6984@gondor.apana.org.au> <20110301123250.GA7368@gondor.apana.org.au> <1298984669.3284.99.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:58658 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab1CANMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2011 08:12:14 -0500
Content-Disposition: inline
In-Reply-To: <1298984669.3284.99.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2011 at 02:04:29PM +0100, Eric Dumazet wrote:
> Well, some machines have 4096 cpus ;)

Well just change it to use the multiplication then :)
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
