From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: af_packet & CHECKSUM_HW
Date: Mon, 17 Nov 2003 07:51:46 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031116205146.GA8477@gondor.apana.org.au>
References: <20031115024434.GA12276@gondor.apana.org.au> <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@redhat.com>
Content-Disposition: inline
In-Reply-To: <Xine.LNX.4.44.0311160841500.31201-100000@thoron.boston.redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Nov 16, 2003 at 08:44:38AM -0500, James Morris wrote:
> On Sat, 15 Nov 2003, Herbert Xu wrote:
>
> > In other words, what do I tell confused users who see bad checksums
> > in the tcpdump output over loopback and interfaces capable of
> > hardware checksums?
> 
> That this functionality does not belong in the kernel, as it serves no
> real purpose.

OK, I will quote you on that :)
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
