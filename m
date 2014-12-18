From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] cxgb4: Fix decoding QSA module for ethtool get
 settings
Date: Thu, 18 Dec 2014 12:39:59 -0500 (EST)
Message-ID: <20141218.123959.1447449165595037274.davem@davemloft.net>
References: <1418817960-17277-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47018 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaLRRkB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 12:40:01 -0500
In-Reply-To: <1418817960-17277-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Wed, 17 Dec 2014 17:36:00 +0530

> QSA module was getting decoded as QSFP module in ethtool get settings, this
> patch fixes it.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
