From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] add new nfnetlink_log subsystem
Date: Sat, 30 Jul 2005 21:00:40 -0700 (PDT)
Message-ID: <20050730.210040.21391542.davem@davemloft.net>
References: <20050730103005.GB6620@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@gnumonks.org
In-Reply-To: <20050730103005.GB6620@rama.de.gnumonks.org>
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

From: Harald Welte <laforge@gnumonks.org>
Date: Sat, 30 Jul 2005 12:30:05 +0200

> This (long-awaited) patch adds the generic nfnetlink-based userspace
> logging.  nfnetlink_log can be used for any protocol family, and
> supports upt to 65535 logging groups (that could go to separate logging
> daemons, e.g.).
> 
> The patch is incremental to my nf_log update in
> <20050728200434.GA3763@rama.de.gnumonks.org>.

Applied, thanks Harald.
