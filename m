From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] tipc: some improvements and fixes
Date: Wed, 25 Mar 2015 14:07:24 -0400 (EDT)
Message-ID: <20150325.140724.235511476328908428.davem@davemloft.net>
References: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48436 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751172AbbCYSH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:07:26 -0400
In-Reply-To: <1427299646-31680-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 25 Mar 2015 12:07:23 -0400

> We introduce a better algorithm for selecting when and which
> users should be subject to link congestion control, plus clean
> up some code for that mechanism.
> Commit #3 fixes another rare race condition during packet reception.

Series applied, thanks Jon.
