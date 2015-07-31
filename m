From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/12] tipc: separate link aggregation from
 link layer
Date: Thu, 30 Jul 2015 17:25:34 -0700 (PDT)
Message-ID: <20150730.172534.1065031641837828725.davem@davemloft.net>
References: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42281 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751013AbbGaAZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 20:25:35 -0400
In-Reply-To: <1438295066-29655-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Thu, 30 Jul 2015 18:24:14 -0400

> We continue the work on separating the roles of the link aggregation and
> link layers, as well as making code cleanups in general.
> 
> This second commit batch focuses on moving the orchestration of link
> failover and synchronization to the node level, as well as preparing the
> node lock structure for further future impovements. We also make some
> changes to message delivery between link and socket layer, in order to
> make this mechanism safer and less obscure.

Series applied, thanks Jon.
