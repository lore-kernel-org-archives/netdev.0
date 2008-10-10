From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: gre: fix copy and paste error
Date: Fri, 10 Oct 2008 23:57:32 +0800
Message-ID: <20081010155732.GA32182@gondor.apana.org.au>
References: <48EF7AC0.6080104@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51131 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756934AbYJJP5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 11:57:39 -0400
Content-Disposition: inline
In-Reply-To: <48EF7AC0.6080104@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 10, 2008 at 05:54:40PM +0200, Patrick McHardy wrote:

> commit c7d32967f53c4d3ded69f0e645b7c0848ac8cb1b
> Author: Patrick McHardy <kaber@trash.net>
> Date:   Fri Oct 10 17:53:36 2008 +0200
> 
>     gre: fix copy and paste error
>     
>     The flags are dumped twice, the keys not at all.
>     
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Good catch.

Thanks Patrick!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
