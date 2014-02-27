From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [net-next PATCH 0/5] netfilter: conntrack: optimization, remove
 central spinlock
Date: Thu, 27 Feb 2014 18:23:52 +0100
Message-ID: <20140227172352.GA15880@localhost>
References: <20140227163950.24668.55934.stgit@dragon>
 <20140227181522.09549165@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140227181522.09549165@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 27, 2014 at 06:15:22PM +0100, Jesper Dangaard Brouer wrote:
> Hi Pablo,
> 
> This should obviously have been for nf-next, and I also forgot to cc
> netfilter-devel@vger.kernel.org ... do you want me to repost?

Yes please, I would like to make sure that anyone on nf-devel can also
have a look at this.

Thanks Jesper.
