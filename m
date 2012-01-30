From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: fix up stale paths from driver
 reorg
Date: Mon, 30 Jan 2012 12:55:30 -0500 (EST)
Message-ID: <20120130.125530.1128002667645019844.davem@davemloft.net>
References: <1327707361-30274-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752382Ab2A3Rzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 12:55:37 -0500
In-Reply-To: <1327707361-30274-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Fri, 27 Jan 2012 18:36:01 -0500

> The reorganization of the driver layout in drivers/net
> left behind some stale paths in comments and in Kconfig
> help text.  Bring them up to date.  No actual change to
> any code takes place here.
> 
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied.
