From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Where exactly will arch_fast_hash be used
Date: Thu, 4 Dec 2014 23:47:08 +0800
Message-ID: <20141204154708.GA22185@gondor.apana.org.au>
References: <20141204081147.GA19030@gondor.apana.org.au>
 <20141204152637.GA32140@casper.infradead.org>
 <20141204152929.GA22075@gondor.apana.org.au>
 <20141204153938.GC32140@casper.infradead.org>
 <54808123.8000704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <54808123.8000704@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Dec 04, 2014 at 04:43:31PM +0100, Daniel Borkmann wrote:
>
> Hm, I thought the kernel doc on arch_fast_hash() in include/linux/hash.h
> would give enough of a hint ...

I think something more explicit like "do not use this in a hash
table unless you know what you're doing" might be needed.

Cheers,
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
