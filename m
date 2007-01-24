From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Wed, 24 Jan 2007 18:06:29 +1100
Message-ID: <20070124070629.GA20398@gondor.apana.org.au>
References: <20070123.221918.35467190.davem@davemloft.net> <E1H9c3T-0005HA-00@gondolin.me.apana.org.au> <20070124.160541.07096404.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nakam@linux-ipv6.org, takamiya@po.ntts.co.jp,
	netdev@vger.kernel.org
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2087 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933177AbXAXHGh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 02:06:37 -0500
Content-Disposition: inline
In-Reply-To: <20070124.160541.07096404.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 24, 2007 at 04:05:41PM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> The only reason they (not myself :-)) want to put this in is
> because the RFC says that MIP6 implementation MUST compute
> checksum by default when it passes the MH to userspace.  On
> the other hand, it also states that user space application SHOULD
> set IPV6_CHECKSUM to 4.

OK if the RFC says so then it's fine by me :)
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
