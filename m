From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netdevice: Update netif_dbg for CONFIG_DYNAMIC_DEBUG
Date: Wed, 30 May 2012 16:34:40 -0400 (EDT)
Message-ID: <20120530.163440.159718684767059040.davem@davemloft.net>
References: <1338399814.3715.6.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jim.cromie@gmail.com, jbaron@redhat.com
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41616 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754120Ab2E3Ues (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2012 16:34:48 -0400
In-Reply-To: <1338399814.3715.6.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Wed, 30 May 2012 10:43:34 -0700

> Make netif_dbg use dynamic debugging whenever
> CONFIG_DYNAMIC_DEBUG is enabled.
> 
> commit b558c96ffa53
> ("dynamic_debug: make dynamic-debug supersede DEBUG ccflag")
> missed updating the netif_dbg variant.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
