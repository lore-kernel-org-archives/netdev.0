From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 08/10] MLSXFRM: Add security context to acquire messages using PF_KEY
Date: Sat, 15 Jul 2006 22:31:27 +1000
Message-ID: <20060715123127.GA18698@gondor.apana.org.au>
References: <44B56642.6060500@trustedcs.com> <20060713.230445.106436593.davem@davemloft.net> <Pine.LNX.4.64.0607140952220.15305@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, vyekkirala@trustedcs.com,
	netdev@vger.kernel.org, Stephen Smalley <sds@tycho.nsa.gov>,
	tjaeger@cse.psu.edu, selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:62482 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1946025AbWGOMbk
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Jul 2006 08:31:40 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0607140952220.15305@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2006 at 09:54:59AM -0400, James Morris wrote:
> 
> Herbert, any review from you on this would be greatly appreciated.

Looks good to me.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
