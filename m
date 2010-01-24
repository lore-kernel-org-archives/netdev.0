From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] netns xfrm: fix "ip xfrm state|policy count" misreport
Date: Sun, 24 Jan 2010 13:12:52 +1300
Message-ID: <20100124001252.GA11585@gondor.apana.org.au>
References: <20100123233709.GA4157@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47201 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750773Ab0AXAM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Jan 2010 19:12:59 -0500
Content-Disposition: inline
In-Reply-To: <20100123233709.GA4157@x200>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 24, 2010 at 01:37:10AM +0200, Alexey Dobriyan wrote:
> "ip xfrm state|policy count" report SA/SP count from init_net,
> not from netns of caller process.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks good to me.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
