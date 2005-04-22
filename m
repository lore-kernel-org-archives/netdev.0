From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9 BUG in tcp_transmit_skb at net/ipv4/tcp_output.c -- full output
Date: Sat, 23 Apr 2005 07:45:08 +1000
Message-ID: <E1DP5xU-0000ZG-00@gondolin.me.apana.org.au>
References: <42691EBC.9040106@nortel.com>
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: cfriesen@nortel.com (Chris Friesen)
In-Reply-To: <42691EBC.9040106@nortel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortel.com> wrote:
> Here's the full output of the bug
> 
> kernel BUG in tcp_transmit_skb at net/ipv4/tcp_output.c:277!

There's been lots of fixes to the TSO code since 2.6.9.  Please test
2.6.11.7 instead.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
