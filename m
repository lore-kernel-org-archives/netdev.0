From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH net-next] netfilter: xt_socket: use sock_gen_put()
Date: Thu, 17 Oct 2013 10:29:26 +0200
Message-ID: <20131017082926.GA7949@localhost>
References: <1381507405.4971.108.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1381507405.4971.108.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 11, 2013 at 09:03:25AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> TCP listener refactoring, part 7 :
> 
> Use sock_gen_put() instead of xt_socket_put_sk() for future
> SYN_RECV support.

Applied, thanks Eric.
