From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [net-2.6.22] [IPV4]: Fix build without procfs.
Date: Wed, 25 Apr 2007 15:49:52 +1000
Message-ID: <20070425054951.GA5505@gondor.apana.org.au>
References: <20070425.002048.109830535.yoshfuji@linux-ipv6.org> <E1HgXMD-0000LK-00@gondolin.me.apana.org.au> <20070425.114650.93714393.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2247 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754584AbXDYFt5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 01:49:57 -0400
Content-Disposition: inline
In-Reply-To: <20070425.114650.93714393.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 11:46:50AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> Herbert, as I said before, we could defer that.
> It was preparation for future development (per-interface statistics
> and netlink interface.

OK, but you better make sure that Adrian Bunk doesn't see them :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
