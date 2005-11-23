From: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Subject: Re: [PATCH 00/13]: Netfilter IPsec support
Date: Wed, 23 Nov 2005 13:52:00 +0900 (JST)
Message-ID: <200511230452.jAN4q1Ok028256@toshiba.co.jp>
References: <4383C31A.40101@trash.net>
	<E1EejY9-0004fW-00@gondolin.me.apana.org.au>
	<20051122.193631.76306901.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	herbert@gondor.apana.org.au, kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051122.193631.76306901.davem@davemloft.net>
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

From: "David S. Miller" <davem@davemloft.net>
Date: Tue, 22 Nov 2005 19:36:31 -0800 (PST)

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Wed, 23 Nov 2005 12:35:53 +1100
> 
> > How about merging the patches that everybody has agreed on first?
> > 
> > So far, I haven't see any objections to patches 1 and 2 so they
> > can go in straight away.  They don't even touch IPv6.
> > 
> > Patches 3-6 could become redundant if you go with my suggestion.
> > 
> > The rest of them I haven't read yet so can't comment :)
> 
> View the net-2.6.16 GIT tree as a sort of playpen, much like
> -mm, until we get close to the real 2.6.16 upstream development
> openning up.
> 
> I rebase all the time, and I can pluck out and change patches
> at will.

Then I agree. It can increase the number of tester, I think.

-- Yasuyuki Kozakai
