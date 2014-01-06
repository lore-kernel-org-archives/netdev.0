From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [net PATCH] netfilter: only warn once on wrong seqadj usage
Date: Mon, 6 Jan 2014 14:23:55 +0100
Message-ID: <20140106132355.GA8798@localhost>
References: <20140104130944.28481.30891.stgit@dragon>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Flavio Leitner <fbl@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20140104130944.28481.30891.stgit@dragon>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jan 04, 2014 at 02:10:43PM +0100, Jesper Dangaard Brouer wrote:
> Avoid potentially spamming the kernel log with WARN splash messages
> when catching wrong usage of seqadj, by simply using WARN_ONCE.
> 
> This is a followup to commit db12cf274353 (netfilter: WARN about
> wrong usage of sequence number adjustments)
> 
> Suggested-by: Flavio Leitner <fbl@redhat.com>
> Suggested-by: Daniel Borkmann <dborkman@redhat.com>
> Suggested-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

Applied, thanks Jesper.
