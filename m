From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] ctnetlink
Date: Fri, 22 Jul 2005 12:48:51 -0700 (PDT)
Message-ID: <20050722.124851.82053896.davem@davemloft.net>
References: <20050722131130.GA26783@rama>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050722131130.GA26783@rama>
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
Date: Fri, 22 Jul 2005 09:11:30 -0400

> This is a patch for your net-2.6.14 tree (incremental to the
> expect-double-free fix).  It adds the ctnetlink code, and all the
> required core conntrack/nat changes that it needs.

Applied and pushed to net-2.6.14
