From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipv6 tunnel stops accepting input
Date: Sat, 15 Jan 2005 23:29:12 +1100
Message-ID: <20050115122912.GA29331@gondor.apana.org.au>
References: <20050111125826.GA25169@wiggy.net> <20050115120323.GA20664@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Wichert Akkerman <wichert@wiggy.net>
Content-Disposition: inline
In-Reply-To: <20050115120323.GA20664@wiggy.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jan 15, 2005 at 01:03:23PM +0100, Wichert Akkerman wrote:
> (Herbert: I did not receive your mail since it seems your mailserver
> refuses the sender verification that exim tries to do).

Hmm, is it still happening now?

> Herbert Xu Wrote:
> >Do you have any netfilter rules?
> 
> I do have a small set of ipv4 netfilter rules. 

Are you using a SIT tunnel? Do you allow SIT traffic initiated
from the outside?

The ICMP message you quoted originally appears to indicate that
you didn't allow SIT traffic intiated from the outside.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
