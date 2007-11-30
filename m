From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [Bugme-new] [Bug 9440] New: Problem in joinning a socket to ipv6 multicast address in specific scenario
Date: Fri, 30 Nov 2007 23:36:42 +1100
Message-ID: <20071130123641.GF26848@gondor.apana.org.au>
References: <bug-9440-10286@http.bugzilla.kernel.org/> <20071122172342.721ee232.akpm@linux-foundation.org> <20071123105924.GB22062@2ka.mipt.ru> <20071128111814.GA10246@2ka.mipt.ru> <20071130120219.GA26848@gondor.apana.org.au> <20071130122516.GA28027@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org, aviad.yehezkel5@gmail.com,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4147 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754602AbXK3Mgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2007 07:36:50 -0500
Content-Disposition: inline
In-Reply-To: <20071130122516.GA28027@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Nov 30, 2007 at 03:25:16PM +0300, Evgeniy Polyakov wrote:
>
> Ok, added netdev_up too.
> 
> Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

Applied to net-2.6.  Thanks Evgeniy!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
