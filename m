From: David Miller <davem@davemloft.net>
Subject: Re: [NET]: Update frag_list in pskb_trim
Date: Thu, 13 Jul 2006 22:05:26 -0700 (PDT)
Message-ID: <20060713.220526.55726160.davem@davemloft.net>
References: <20060713090341.GA28426@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:26338
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S964791AbWGNFFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 01:05:30 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060713090341.GA28426@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Thu, 13 Jul 2006 19:03:41 +1000

> This needs to go into stable as well.  In fact, there is another unrelated
> bug with exactly the same symptoms which was inadvertently fixed by the
> GSO patches.  So I'll send a simpler fix for that to stable.

As I noted already, this is in my tree and will go off to
Linus soon.

Please toss this over to -stable under seperate cover, if
you haven't done so already.  Please add my signoff:

Signed-off-by: David S. Miller <davem@davemloft.net>

if you like.

Thanks.
