From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: IPsec and Path MTU
Date: Wed, 16 Jun 2004 21:43:45 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040616114345.GA1559@gondor.apana.org.au>
References: <20040615124334.GA25164@gondor.apana.org.au> <32703.1087311037@marajade.sandelman.ottawa.on.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kuznet@ms2.inr.ac.ru, davem@redhat.com, jmorris@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Content-Disposition: inline
In-Reply-To: <32703.1087311037@marajade.sandelman.ottawa.on.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jun 15, 2004 at 10:50:37AM -0400, Michael Richardson wrote:
> 
>   The pmtu WG is considering changing how PMTU is done. You may want to 
> look at draft-richardson-ipsec-fragment-XX.txt. This has not yet been
> adopted as a WG draft, because nobody is sure which WG should adopt it:-)

I'd say that we should get the stack to work with the hosts that do send
ICMP replies first, and then worry about those that don't :)
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
