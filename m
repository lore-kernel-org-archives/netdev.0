From: James Morris <jmorris@redhat.com>
Subject: Re: [IPSEC] Make IPCOMP more resilient
Date: Fri, 25 Mar 2005 23:38:12 -0500 (EST)
Message-ID: <Xine.LNX.4.44.0503252337500.24726-100000@thoron.boston.redhat.com>
References: <20050326035853.GA25162@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, Patrick McHardy <kaber@trash.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, <netdev@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050326035853.GA25162@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Mar 2005, Herbert Xu wrote:

> In other words, we can let outbound IPCOMP always succeed.  In the cases
> where it would currently fail we simply skip the IPCOMP transform.  This
> makes IPCOMP slightly more resilient when memory is low and simplifies
> the code quite a bit.

Good idea.


Acked-by: James Morris <jmorris@redhat.com>


- James
-- 
James Morris
<jmorris@redhat.com>
