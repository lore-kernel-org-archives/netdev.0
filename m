From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Add PHY firmware support for T420-BT
 cards
Date: Mon, 25 May 2015 00:17:48 -0400 (EDT)
Message-ID: <20150525.001748.1897260635248782607.davem@davemloft.net>
References: <1432312101-7944-1-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leedom@chelsio.com, nirranjan@chelsio.com
To: hariprasad@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41729 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750845AbbEYERu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 May 2015 00:17:50 -0400
In-Reply-To: <1432312101-7944-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hariprasad Shenai <hariprasad@chelsio.com>
Date: Fri, 22 May 2015 21:58:21 +0530

> Add support for flashing 10GBaseT adapter with BCM 84834 PHY and
> Aquantia AQ1202 PHY.
> 
> Updating of the PHY firmware must happen before the INITIALIZE_CMD.
> 
> Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>

Applied, thanks.
