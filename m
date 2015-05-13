From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: netlink & rhashtable status
Date: Wed, 13 May 2015 13:40:37 +0800
Message-ID: <20150513054037.GA26595@gondor.apana.org.au>
References: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, Thomas Graf <tgraf@suug.ch>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38437 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750909AbbEMFkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 01:40:46 -0400
Content-Disposition: inline
In-Reply-To: <1431495036.566.126.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 10:30:36PM -0700, Eric Dumazet wrote:
> 
> linux-3.17, 3.18, 3.19 and 4.0.2 have issues with netlink/rhashtable,
> making things like getaddrinfo() not working after a while :

Do you use namespaces?

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
