From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/4] ipv6: fix the reassembly expire code
 in nf_conntrack
Date: Tue, 18 Sep 2012 17:44:22 -0400 (EDT)
Message-ID: <20120918.174422.676733596356822897.davem@davemloft.net>
References: <1347942582-23962-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	herbert@gondor.hengli.com.au
To: amwang@redhat.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1347942582-23962-1-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Tue, 18 Sep 2012 12:29:38 +0800

> V2: use IS_ENABLED(CONFIG_IPV6) to fix a build error
>     rebase to latest net-next
> 
> ipv6: add a new namespace for nf_conntrack_reasm
> ipv6: unify conntrack reassembly expire code with standard one
> ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
> ipv6: unify fragment thresh handling code
> 
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Please address Pedro's feedback and resubmit, thanks.
