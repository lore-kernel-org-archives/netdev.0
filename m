From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Move inetdev/ifa over to RCU
Date: Mon, 16 Aug 2004 18:13:54 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040816081354.GA10400@gondor.apana.org.au>
References: <20040812165954.00429e65.davem@redhat.com> <20040813090314.448c971d@dell_ss3.pdx.osdl.net> <20040813093838.6961c0d4.davem@redhat.com> <20040813215602.GA15870@gondor.apana.org.au> <20040813151923.3311b4f0.davem@redhat.com> <20040814003428.GA17760@gondor.apana.org.au> <20040815195820.6b79b3fc.davem@redhat.com> <20040816030826.GA8341@gondor.apana.org.au> <20040815232153.54e95346.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040815232153.54e95346.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Aug 15, 2004 at 11:21:53PM -0700, David S. Miller wrote:
> 
> I totally agree, and let's kill the lock too since it is
> in fact useless now.  I've done this as follows:

That looks great.  Thanks Dave.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
