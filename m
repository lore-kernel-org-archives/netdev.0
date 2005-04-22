From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: 2.6.9 BUG in tcp_transmit_skb at net/ipv4/tcp_output.c -- full output
Date: Sat, 23 Apr 2005 08:32:36 +1000
Message-ID: <20050422223236.GA2425@gondor.apana.org.au>
References: <E1DP5xU-0000ZG-00@gondolin.me.apana.org.au> <426976F2.3000604@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Friesen <cfriesen@nortel.com>
Content-Disposition: inline
In-Reply-To: <426976F2.3000604@nortel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 04:13:06PM -0600, Chris Friesen wrote:
> 
> Unfortunately I can't move to the latest. We have a bunch ofkernel 
> modules from various vendors, board support packages that aren't in 
> mainline, etc.  We're in the process of moving to 2.6.10 and that 
> requires support from six separate companies.  It's a mess.

You could also try going back to 2.6.8.1 since that predates the
TSO restructure.
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
