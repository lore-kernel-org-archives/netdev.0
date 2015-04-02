From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: remove some unnecessary complexity
Date: Thu, 02 Apr 2015 16:27:29 -0400 (EDT)
Message-ID: <20150402.162729.449983442281951801.davem@davemloft.net>
References: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41136 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752148AbbDBU1c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 16:27:32 -0400
In-Reply-To: <1427981582-30819-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu,  2 Apr 2015 09:32:59 -0400

> The TIPC code is unnecessarily complex in some places, often because
> the conditions or assumptions that were the cause for the complexity
> are not valid anymore.
> 
> In these three commits, we eliminate some cases of such redundant
> complexity.

Series applied, thanks Jon.
