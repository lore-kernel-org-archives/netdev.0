From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/5] tipc: netlink updates for neighbour
 monitor
Date: Mon, 25 Jul 2016 10:36:27 -0700 (PDT)
Message-ID: <20160725.103627.1955850625176476362.davem@davemloft.net>
References: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tipc-discussion@lists.sourceforge.net,
	jon.maloy@ericsson.com, maloy@donjonn.com, ying.xue@windriver.com
To: parthasarathy.bhuvaragan@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42624 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611AbcGYRg2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jul 2016 13:36:28 -0400
In-Reply-To: <1469169768-9214-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Date: Fri, 22 Jul 2016 08:42:43 +0200

> This series contains the updates to configure and read the attributes for
> neighbour monitor.
> 
> Parthasarathy Bhuvaragan (5):
>   tipc: introduce constants for tipc address validation
>   tipc: make cluster size threshold for monitoring configurable
>   tipc: get monitor threshold for the cluster
>   tipc: add a function to get the bearer name
>   tipc: dump monitor attributes

This series no longer applies cleanly to net-next, please respin.

Thanks.
