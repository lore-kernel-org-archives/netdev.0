From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC/PATCH] "strict" ipv4 reassembly
Date: Wed, 18 May 2005 10:10:54 +1000
Message-ID: <20050518001054.GB27212@gondor.apana.org.au>
References: <E1DYBED-0006wa-00@gondolin.me.apana.org.au> <Pine.LNX.4.61.0505171612440.3335@linux.site> <20050517232556.GA26846@gondor.apana.org.au> <428A871F.1000308@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arthur Kepner <akepner@sgi.com>, dlstevens@us.ibm.com, rick.jones2@hp.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Nivedita Singhvi <niv@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <428A871F.1000308@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, May 17, 2005 at 05:06:55PM -0700, Nivedita Singhvi wrote:
> 
> Mainline linux certainly has this (per-inetpeer ip_id) - but
> at least one distro did not (use inetpeer) :). Not sure
> what the current situation is.

What was the reason for this? Perhaps we can solve their problems
with inetpeer in a better way than disabling it?

> Of course, if all the traffic is on the same connection
> (which isn't out of the ordinary) would still come down
> to the same thing...

Please see my proposal elsewhere in this thread.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
