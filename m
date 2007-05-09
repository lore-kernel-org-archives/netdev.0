From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: linkwatch bustage in git-net
Date: Wed, 9 May 2007 15:54:05 +1000
Message-ID: <20070509055405.GA1336@gondor.apana.org.au>
References: <20070508222033.4e57a580.akpm@linux-foundation.org> <20070509053154.GA850@gondor.apana.org.au> <20070509054558.GA1184@gondor.apana.org.au> <20070508225153.d538f79c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4784 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751076AbXEIFyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 01:54:11 -0400
Content-Disposition: inline
In-Reply-To: <20070508225153.d538f79c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 08, 2007 at 10:51:53PM -0700, Andrew Morton wrote:
> 
> It's not hanging.  It's just going reeeeeeeaaaaallllllyyyy sslllooowwllyyy.
> 
> This is first noticeable during udev startup and persists all the way
> through initscripts.

OK, does reverting the link watch patches make this go away?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
