From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [7/*] [IPSEC] Get metrics for xfrm_dst from top dst
Date: Mon, 7 Mar 2005 21:41:43 +1100
Message-ID: <20050307104143.GB7851@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050216103744.GA476@gondor.apana.org.au> <20050216110842.GA1024@gondor.apana.org.au> <20050216113836.GA1652@gondor.apana.org.au> <20050306214754.7a1839e1.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050306214754.7a1839e1.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, Mar 06, 2005 at 09:47:54PM -0800, David S. Miller wrote:
> 
> This is the last patch I saw in this series.  Any more stuff
> you have ready to apply in this area?

I've just sent you two fix-up's.  I'll work on the clean-up's
that I talked about next.  Once that's done we can consider
the first step in the MTU rework complete.

The next step would be to relay ICMP information back to the
sender.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
