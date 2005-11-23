From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Wed, 23 Nov 2005 12:35:53 +1100
Message-ID: <E1EejY9-0004fW-00@gondolin.me.apana.org.au>
References: <4383C31A.40101@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <4383C31A.40101@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> I would appreciate that, but I want to have a look closer look
> at Herbert's patches first. Unfortunately its late and I have
> to get up early, so its going to take me a day.

How about merging the patches that everybody has agreed on first?

So far, I haven't see any objections to patches 1 and 2 so they
can go in straight away.  They don't even touch IPv6.

Patches 3-6 could become redundant if you go with my suggestion.

The rest of them I haven't read yet so can't comment :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
