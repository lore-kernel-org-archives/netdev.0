From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [XFRM] Make XFRM core subsystem af-independent
Date: Sat, 18 Sep 2004 10:12:16 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040918001216.GB24235@gondor.apana.org.au>
References: <E1C8I2m-0005BS-00@gondolin.me.apana.org.au> <20040917.231127.114842301.yoshfuji@linux-ipv6.org> <20040917153536.6acec52e.davem@davemloft.net> <20040918.085003.77842779.yoshfuji@linux-ipv6.org> <20040917170607.2e96b58a.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040917170607.2e96b58a.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Sep 17, 2004 at 05:06:07PM -0700, David S. Miller wrote:
> 
> Compiler is smarter than you think :-)

Sparc bigots :)

Unfortunately it can't do that on architectures where the arguments
are pushed onto the stack in reverse order, i.e., i386.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
