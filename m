From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: oops with 2.6.23.1, marvel, software raid, reiserfs and samba
Date: Sun, 16 Dec 2007 20:21:47 +0800
Message-ID: <20071216122147.GA4355@gondor.apana.org.au>
References: <20071216030516.1562a5d0.akpm@linux-foundation.org> <E1J3s76-000166-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@jeffunit.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1878 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1765507AbXLPMVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Dec 2007 07:21:52 -0500
Content-Disposition: inline
In-Reply-To: <E1J3s76-000166-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 16, 2007 at 07:56:56PM +0800, Herbert Xu wrote:
>
> What's spooky is that I just did a google and we've had reports
> since 1998 all crashing on exactly the same line in tcp_recvmsg.

However, there's been no reports at all since 2000 apart from this
one so the earlier ones are probably not related.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
