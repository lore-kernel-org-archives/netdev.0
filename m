From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 06/13]: [IPV4/6]: Netfilter IPsec input hooks
Date: Mon, 21 Nov 2005 18:47:12 +1100
Message-ID: <E1Ee6OO-0005YD-00@gondolin.me.apana.org.au>
References: <20051120.230034.105307423.davem@davemloft.net>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, yasuyuki.kozakai@toshiba.co.jp
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net (David S. Miller)
In-Reply-To: <20051120.230034.105307423.davem@davemloft.net>
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

David S. Miller <davem@davemloft.net> wrote:
> 
> I've read over Patrick's two most recent postings of these patches
> and I think they are generally sane and I cannot find any holes in
> them.  Herbert brought up the legitimate concern about defragmentation,
> but I think that's a detail and does not take away from the structural
> soundness of Patrick's approach.

Yes I agree completely.  The new IPsec stack has been around for three
years and it's about time that we have proper netfilter support for it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
