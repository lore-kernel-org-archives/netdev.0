From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 12:33:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831023322.GA31201@gondor.apana.org.au>
References: <20040831013841.GA5824@sunbeam.de.gnumonks.org> <E1C1yGT-000859-00@gondolin.me.apana.org.au> <20040830192458.1476df60.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: laforge@netfilter.org, netfilter-devel@lists.netfilter.org,
        rusty@rustcorp.com.au, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040830192458.1476df60.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 30, 2004 at 07:24:58PM -0700, David S. Miller wrote:
> On Tue, 31 Aug 2004 12:20:53 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > So it would be good to know why the oif key is a bad idea.
> 
> I'm OK with removing the oif check, but I'm not OK with the
> idea of specifying a specific output interface in the
> route lookup flow key here.

Can you please give a reason for that?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
