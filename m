From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Ripping out old hard-wired
 initialization code in driver
Date: Tue, 13 Jan 2015 16:53:11 -0500 (EST)
Message-ID: <20150113.165311.1281801164481476926.davem@davemloft.net>
References: <1421142565-10232-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbAMVxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 16:53:14 -0500
In-Reply-To: <1421142565-10232-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Tue, 13 Jan 2015 15:19:25 +0530

> Removing old hard-wired initialization code in the driver, which is no longer
> used. Also deprecating few module parameters.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied.
