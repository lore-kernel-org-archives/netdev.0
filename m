From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] Too aggressive cwnd backoff
Date: Fri, 08 Apr 2005 07:42:18 +1000
Message-ID: <E1DJelW-0007Vg-00@gondolin.me.apana.org.au>
References: <20050407113351.17f8c094.davem@davemloft.net>
Cc: baruch@ev-en.org, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20050407113351.17f8c094.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

David S. Miller <davem@davemloft.net> wrote:
> 
> I don't disagree with your analysis at all.  I just want to find out
> if it did change in the vanilla sources.  Because if it did we can
> track down a changelog message and perhaps learn something about what
> the code is the way it is.

Looking at the vger tree this was introduced back in 2000:

# ChangeSet
#   2000/08/09 11:59:05-00:00 davem@vger.kernel.org
#   Many files:
#     Merge in ANKs net-000808-23:20 patch.
#     Linus better eat this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
