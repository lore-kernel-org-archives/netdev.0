From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mipsnet: Remove the MIPSsim Ethernet driver.
Date: Mon, 24 Sep 2012 16:41:30 -0400 (EDT)
Message-ID: <20120924.164130.1073842749430205590.davem@davemloft.net>
References: <1348498036-30257-1-git-send-email-sjhill@mips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org,
	ralf@linux-mips.org
To: sjhill@mips.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54305 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757887Ab2IXUld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 16:41:33 -0400
In-Reply-To: <1348498036-30257-1-git-send-email-sjhill@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Steven J. Hill" <sjhill@mips.com>
Date: Mon, 24 Sep 2012 09:47:16 -0500

> From: "Steven J. Hill" <sjhill@mips.com>
> 
> The MIPSsim platform is no longer supported or used. This patch
> deletes the Ethernet driver.
> 
> Signed-off-by: Steven J. Hill <sjhill@mips.com>

I'll apply this to net-next, thanks.
