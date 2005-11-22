From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] NETFILTER arp_tables: Fix NUMA optimization
Date: Tue, 22 Nov 2005 14:28:36 -0800 (PST)
Message-ID: <20051122.142836.54484918.davem@davemloft.net>
References: <437CA009.4020006@cosmosbay.com>
	<20051118.160043.119281166.davem@davemloft.net>
	<20051119103131.GE20775@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	dada1@cosmosbay.com
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20051119103131.GE20775@sunbeam.de.gnumonks.org>
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
Date: Sat, 19 Nov 2005 11:31:31 +0100

> There's another one that I detected while merging those changes with
> x_tables (painful).  Please merge:
> 
> [NETFILTER] arp_tables: Fix bug introduced with NUMA aware allocation
> 
> This fix shows how bad I am with copy & paste.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Added to net-2.6.16, thanks a lot.
