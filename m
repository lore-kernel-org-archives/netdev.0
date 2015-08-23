From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: fix link failover/synch problems
Date: Sun, 23 Aug 2015 16:15:01 -0700 (PDT)
Message-ID: <20150823.161501.1555147023417416861.davem@davemloft.net>
References: <1440051176-32672-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbbHWXPD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Aug 2015 19:15:03 -0400
In-Reply-To: <1440051176-32672-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 20 Aug 2015 02:12:53 -0400

> We fix three problems with the new link failover/synch implementation,
> which was introduced earlier in this release cycle. They are all related
> to situations where there is a very short interval between the disabling
> and enabling of interfaces.

Series applied, thanks Jon.
