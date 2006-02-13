From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] 2.6.16: [NETFILTER] Fix Kconfig menu level for x_tables
Date: Mon, 13 Feb 2006 15:42:59 -0800 (PST)
Message-ID: <20060213.154259.21716277.davem@davemloft.net>
References: <20060213110600.GQ4601@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20060213110600.GQ4601@sunbeam.de.gnumonks.org>
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
Date: Mon, 13 Feb 2006 12:06:00 +0100

> [NETFILTER] Fix Kconfig menu level for x_tables
> 
> The new x_tables related Kconfig options appear at the wrong menu level
> without this patch.
> 
> Signed-off-by: Harald Welte <laforge@netfilter.org>

Applied, thanks Harald.
