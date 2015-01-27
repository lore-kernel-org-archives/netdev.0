From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] rhashtable: Introduce rhashtable_walk_*
Date: Wed, 28 Jan 2015 10:16:22 +1100
Message-ID: <20150127231622.GA11287@gondor.apana.org.au>
References: <20150127112304.GA4548@gondor.apana.org.au>
 <20150127114028.GG22262@casper.infradead.org>
 <20150127203924.GB9061@gondor.apana.org.au>
 <20150127.141018.1208673547021029175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: tgraf@suug.ch, David.Laight@ACULAB.COM, ying.xue@windriver.com,
	kaber@trash.net, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:43987 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752259AbbA0XQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 18:16:57 -0500
Content-Disposition: inline
In-Reply-To: <20150127.141018.1208673547021029175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2015 at 02:10:18PM -0800, David Miller wrote:
>
> For netlink a linked list is no big deal, but for something like TCP
> sockets it really is.

OK then I'll resubmit my iterators.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
