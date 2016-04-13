From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: remove remnants of old broadcast
 code
Date: Wed, 13 Apr 2016 17:50:15 -0400 (EDT)
Message-ID: <20160413.175015.1189895883567923026.davem@davemloft.net>
References: <1460562347-26436-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754251AbcDMVuU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2016 17:50:20 -0400
In-Reply-To: <1460562347-26436-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 13 Apr 2016 11:45:47 -0400

> We remove a couple of leftover fields in struct tipc_bearer. Those
> were used by the old broadcast implementation, and are not needed
> any longer. There is no functional changes in this commit.
> 
> Acked-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thank you.
