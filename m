From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Tue, 2 Nov 2004 09:06:44 +1100
Message-ID: <20041101220644.GA23903@gondor.apana.org.au>
References: <20041030030936.GA25102@lists.us.dell.com> <1099163419.1039.97.camel@jzny.localdomain> <20041101044433.GA18772@lists.us.dell.com> <20041101173434.GA12437@lists.us.dell.com> <20041101202754.GA23149@gondor.apana.org.au> <20041101203821.GA15086@lists.us.dell.com> <20041101204131.GA23277@gondor.apana.org.au> <20041101204533.GA17279@lists.us.dell.com> <1099345849.1073.1.camel@jzny.localdomain> <20041101215944.GB17279@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Domsch <Matt_Domsch@dell.com>
Content-Disposition: inline
In-Reply-To: <20041101215944.GB17279@lists.us.dell.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Nov 01, 2004 at 03:59:44PM -0600, Matt Domsch wrote:
> 
> Actually, -EOVERFLOW appears throughout the kernel.  A couple examples:

I agree.  Please disregard my comment re ERANGE.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
