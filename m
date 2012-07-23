From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlx4: Add support for EEH error recovery
Date: Mon, 23 Jul 2012 14:34:36 -0700 (PDT)
Message-ID: <20120723.143436.2124127996154789223.davem@davemloft.net>
References: <500D93F5.4090305@linux.vnet.ibm.com>
	<500DB9CE.5080100@linux.vnet.ibm.com>
	<CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: klebers@linux.vnet.ibm.com, ogerlitz@mellanox.com,
	netdev@vger.kernel.org, jackm@dev.mellanox.co.il,
	yevgenyp@mellanox.co.il, cascardo@linux.vnet.ibm.com,
	brking@linux.vnet.ibm.com, shlomop@mellanox.com
To: or.gerlitz@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49881 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754768Ab2GWVej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 17:34:39 -0400
In-Reply-To: <CAJZOPZJP9OaZVB03kKGtWvrUUb8B--wUNX9z3MG_MNmKr8U3kQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <or.gerlitz@gmail.com>
Date: Tue, 24 Jul 2012 00:26:51 +0300

> I wasn't sure to follow what did you mean by "it didn't affect the EEH
> recovery", how did you use the aer_inject module, is that through
> user-space tool which is available for us?

Can we please move forward, if he implemented the feature properly
and he tested it successfully, unless you can find a logic or
stylistic flaw in his patch please ACK it.

You can't hold his changes back while you work out how _YOU_ can
test it to your liking.
