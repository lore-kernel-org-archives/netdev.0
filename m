From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Tue, 22 Nov 2005 19:36:31 -0800 (PST)
Message-ID: <20051122.193631.76306901.davem@davemloft.net>
References: <4383C31A.40101@trash.net>
	<E1EejY9-0004fW-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <E1EejY9-0004fW-00@gondolin.me.apana.org.au>
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

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 23 Nov 2005 12:35:53 +1100

> How about merging the patches that everybody has agreed on first?
> 
> So far, I haven't see any objections to patches 1 and 2 so they
> can go in straight away.  They don't even touch IPv6.
> 
> Patches 3-6 could become redundant if you go with my suggestion.
> 
> The rest of them I haven't read yet so can't comment :)

View the net-2.6.16 GIT tree as a sort of playpen, much like
-mm, until we get close to the real 2.6.16 upstream development
openning up.

I rebase all the time, and I can pluck out and change patches
at will.
