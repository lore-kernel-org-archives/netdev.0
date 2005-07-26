From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] move ip[6]_queue rerouting up to nf_queue
Date: Tue, 26 Jul 2005 16:13:00 -0700 (PDT)
Message-ID: <20050726.161300.12130036.davem@davemloft.net>
References: <20050726164505.GD4279@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050726164505.GD4279@rama.de.gnumonks.org>
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
Date: Tue, 26 Jul 2005 18:45:05 +0200

> please apply.  If you dislike the yet-another-NPROTO nature of it, I'll
> prepare one with kmalloc-at-startup.

Please do, thanks.
