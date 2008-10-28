From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Error: an inet prefix is expected rather than "0/0".
Date: Tue, 28 Oct 2008 09:51:34 +0800
Message-ID: <20081028015134.GA8103@gondor.apana.org.au>
References: <alpine.LNX.1.10.0810082331010.13921@bizon.gios.gov.pl> <E1KpkSl-00087W-GB@gondolin.me.apana.org.au> <20081014104621.3c2ce4d3@extreme> <20081015014624.GA3251@gondor.apana.org.au> <m34p3door9.fsf@maximus.localdomain> <1224086831.3984.196.camel@achroite> <m3y70pn11c.fsf@maximus.localdomain> <20081027103950.7eba4fe1@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Krzysztof Halasa <khc@pm.waw.pl>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Krzysztof Oledzki <ole@ans.pl>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:47818 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752221AbYJ1Bvv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 21:51:51 -0400
Content-Disposition: inline
In-Reply-To: <20081027103950.7eba4fe1@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 27, 2008 at 10:39:50AM -0700, Stephen Hemminger wrote:
>
> I ended up putting in a version similar to the original code but with
> more error checking so it would not accept 259.1 etc.

Thanks Stephen!
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
