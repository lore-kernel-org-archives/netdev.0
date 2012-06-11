From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] phy: Use pr_<level>
Date: Mon, 11 Jun 2012 16:59:04 -0700 (PDT)
Message-ID: <20120611.165904.1263417067457821204.davem@davemloft.net>
References: <1339264147.5848.4.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752702Ab2FKX7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 19:59:04 -0400
In-Reply-To: <1339264147.5848.4.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Sat, 09 Jun 2012 10:49:07 -0700

> Use a more current logging style.
> 
> Add pr_fmt and missing newlines.
> Remove embedded prefixes.
> Neaten phy_print_status to avoid using KERN_CONT.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks Joe.
