From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: isdn: Fix dependency for ISDN_PPP
Date: Tue, 10 Jan 2012 14:57:39 -0800 (PST)
Message-ID: <20120110.145739.737678892636016665.davem@davemloft.net>
References: <1326196463-8727-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de,
	fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46915 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933254Ab2AJW5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2012 17:57:47 -0500
In-Reply-To: <1326196463-8727-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Tue, 10 Jan 2012 09:54:23 -0200

> Fix the following build warning:
> 
> warning: (ISDN_PPP) selects SLHC which has unmet direct dependencies (NETDEVICES)
> 
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
