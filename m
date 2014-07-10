From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cpmac: fix in debug messages
Date: Thu, 10 Jul 2014 16:55:36 -0700 (PDT)
Message-ID: <20140710.165536.354400157362107483.davem@davemloft.net>
References: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mugunthanvnm@ti.com,
	linux@rainbow-software.org, balbi@ti.com, george.cherian@ti.com,
	varkab@cdac.in
To: varkabhadram@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46159 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751142AbaGJXzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2014 19:55:37 -0400
In-Reply-To: <1404986378-28555-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: varkabhadram@gmail.com
Date: Thu, 10 Jul 2014 15:29:38 +0530

> From: Varka Bhadram <varkab@cdac.in>
> 
> This patch fix the debug message format. This patch changes to the
> commit f160a2d0b524eeebd97a68e2fbb59fad4cdd3fee: net: cpmac: dynamic debug fixes
> 
> When we use pr_debug()/netdev_dbg() new lines are inserting in b/w
> the values. The format when i use the printk()
> 
> These formats used in skb dump and reg dump. This functions
> called from the entire code. So this will be enabled all the lines.
> 
> Signed-off-by: Varka Bhadram <varkab@cdac.in>

Applied, thank you.
