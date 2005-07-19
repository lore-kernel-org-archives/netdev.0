From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] convert nfmark and conntrack mark to 32bit
Date: Mon, 18 Jul 2005 20:29:07 -0700 (PDT)
Message-ID: <20050718.202907.89039929.davem@davemloft.net>
References: <20050717214223.GA13434@rama.risq.ericsson.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050717214223.GA13434@rama.risq.ericsson.ca>
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

From: Harald Welte <laforge@netfilter.org>
Date: Sun, 17 Jul 2005 23:42:23 +0200

> As discussed at netconf'05, we convert nfmark and conntrack-mark to be
> 32bits even on 64bit architectures. 
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
