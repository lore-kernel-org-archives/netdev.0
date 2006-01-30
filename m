From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] [NETFILTER] nfnetlink_log: add sequence numbers for
 log events
Date: Mon, 30 Jan 2006 15:50:56 -0800 (PST)
Message-ID: <20060130.155056.41617808.davem@davemloft.net>
References: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
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
Date: Tue, 31 Jan 2006 00:23:48 +0100

> [NETFILTER] nfnetlink_log: add sequence numbers for log events
> 
> By using a sequence number for every logged netfilter event, we can
> determine from userspace whether logging information was lots somewhere
> downstream.
> 
> The user has a choice of either having per-instance local sequence
> counters, or using a global sequence counter, or both.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Also applied to net-2.6.17, thanks.
