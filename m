From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] tun: Convert logging messages to pr_<level> and
 tun_debug
Date: Thu, 03 Mar 2011 12:21:42 -0800 (PST)
Message-ID: <20110303.122142.179945626.davem@davemloft.net>
References: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43006
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758524Ab1CCUVF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 15:21:05 -0500
In-Reply-To: <7f33dcacd277e127208211d8c3ef11c992408628.1299086044.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed,  2 Mar 2011 09:18:10 -0800

> Use the current logging forms with pr_fmt.
> Convert DBG macro to tun_debug, use netdev_printk as well.
> Add printf verification when TUN_DEBUG not defined.
> Miscellaneous comment typo fix.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
