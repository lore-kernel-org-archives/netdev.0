From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tipc: name distributor pernet queue
Date: Mon, 11 Apr 2016 15:22:59 -0400 (EDT)
Message-ID: <20160411.152259.1584867440804866074.davem@davemloft.net>
References: <1460040044-30770-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	parthasarathy.bhuvaragan@ericsson.com, richard.alpe@ericsson.com,
	ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754087AbcDKTXB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Apr 2016 15:23:01 -0400
In-Reply-To: <1460040044-30770-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  7 Apr 2016 10:40:42 -0400

> Commit #1 fixes a potential issue with deferred binding table 
> updates being pushed to the wrong namespace.
> 
> Commit #2 solves a problem with deferred binding table updates
> remaining in the the defer queue after the issuing node has gone
> down.

Series applied, thanks.
