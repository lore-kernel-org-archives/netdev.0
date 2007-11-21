From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv6 0/3] Interface group patches
Date: Tue, 20 Nov 2007 17:17:43 -0800 (PST)
Message-ID: <20071120.171743.04294220.davem@davemloft.net>
References: <4742E68C.2000802@balabit.hu>
	<20071120.134242.177093096.davem@davemloft.net>
	<47437B12.9090009@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, jengelh@computergmbh.de,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47437B12.9090009@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 21 Nov 2007 01:25:54 +0100

> I'm working on the incremental ruleset changing API BTW :)
> One of the changes will be that interface matching is not
> a default part of every rule, and without wildcards it will
> use the ifindex. But since the cost of this feature seems
> pretty low, I don't see a compelling reason against it.

Fair enough :)
