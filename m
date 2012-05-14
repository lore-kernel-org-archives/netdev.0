From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter/xt_CT.c: remove redundant header include
Date: Mon, 14 May 2012 10:25:04 +0200
Message-ID: <20120514082504.GC9577@1984>
References: <1336601016-19495-1-git-send-email-eldad@fogrefinery.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eldad Zack <eldad@fogrefinery.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1336601016-19495-1-git-send-email-eldad@fogrefinery.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, May 10, 2012 at 12:03:35AM +0200, Eldad Zack wrote:
> nf_conntrack_l4proto.h is included twice.

Applied, thanks.
