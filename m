From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ipv6: fix the reassembly expire code in
 nf_conntrack
Date: Mon, 17 Sep 2012 12:54:19 -0400 (EDT)
Message-ID: <20120917.125419.1478223385564528540.davem@davemloft.net>
References: <1347517541-10653-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: amwang@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347517541-10653-1-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Thu, 13 Sep 2012 14:25:37 +0800

> ipv6: add a new namespace for nf_conntrack_reasm
> ipv6: unify conntrack reassembly expire code with
> ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
> ipv6: unify fragment thresh handling code
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

These changes look great, all applied to net-next, thanks.
