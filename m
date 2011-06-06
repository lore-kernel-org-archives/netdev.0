From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix smc91x.c device tree support
Date: Sun, 05 Jun 2011 17:03:01 -0700 (PDT)
Message-ID: <20110605.170301.571912692972468276.davem@davemloft.net>
References: <20110604073127.27163.47519.stgit@ponder>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	thomas@wytron.com.tw
To: grant.likely@secretlab.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53811 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab1FFADH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 20:03:07 -0400
In-Reply-To: <20110604073127.27163.47519.stgit@ponder>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Likely <grant.likely@secretlab.ca>
Date: Sat, 04 Jun 2011 01:31:27 -0600

> Fix missing semicolon at end of smc91x.c match tabledevice driver.
> Also remove unnecessary #ifdef around of_match_table pointer.
> 
> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>

Applied, thanks Grant.
