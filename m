From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 3/6] netfilter: bridge: switch hook PFs to nfproto
Date: Wed, 6 Jun 2012 02:03:05 +0200
Message-ID: <20120606000305.GC27266@1984>
References: <1337003799-2517-1-git-send-email-alban.crequy@collabora.co.uk>
 <1337003799-2517-3-git-send-email-alban.crequy@collabora.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>,
	Vincent Sanders <vincent.sanders@collabora.co.uk>,
	Javier Martinez Canillas <javier.martinez@collabora.co.uk>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Alban Crequy <alban.crequy@collabora.co.uk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1337003799-2517-3-git-send-email-alban.crequy@collabora.co.uk>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 14, 2012 at 02:56:36PM +0100, Alban Crequy wrote:
> NFPROTO_* constants were usually equal to PF_* constants but it is not
> necessary and it will waste less memory if we don't do so (see commit 7e9c6e
> "netfilter: Introduce NFPROTO_* constants")

Applied, thanks.
