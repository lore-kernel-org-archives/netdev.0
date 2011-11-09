From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Add IPSec IP Range in Linux kernel
Date: Wed, 9 Nov 2011 09:54:06 +0800
Message-ID: <20111109015406.GA10800@gondor.apana.org.au>
References: <20111108.204253.891598837549584662.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: danila.st@mail.ru, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	linux-security-module@vger.kernel.org, adobriyan@gmail.com,
	peter.p.waskiewicz.jr@intel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111108.204253.891598837549584662.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
>
> Like I said, if you want address ranges, ask the userland IPSEC daemon
> authors to synthesize it.

Alternatively you can do this with marking and use netfilter
to set the mark.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
