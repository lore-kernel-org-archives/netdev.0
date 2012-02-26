From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] netlink: add netlink_dump_control structure for
 netlink_dump_start()
Date: Sun, 26 Feb 2012 14:26:58 -0500 (EST)
Message-ID: <20120226.142658.2102259598074884751.davem@davemloft.net>
References: <1330129817-28199-1-git-send-email-pablo@netfilter.org>
	<1330129817-28199-2-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1330129817-28199-2-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Sat, 25 Feb 2012 01:30:15 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Davem considers that the argument list of this interface is getting
> out of control. This patch tries to address this issue following
> his proposal:
> 
> struct netlink_dump_control c = { .dump = dump, .done = done, ... };
> 
> netlink_dump_start(..., &c);
> 
> Suggested by David S. Miller.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.
