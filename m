From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] qlcnic: VXLAN offload support
Date: Mon, 24 Mar 2014 00:44:57 -0400 (EDT)
Message-ID: <20140324.004457.610782195952103591.davem@davemloft.net>
References: <1395391278-19653-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dept-HSGLinuxNICDev@qlogic.com
To: shahed.shaikh@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750753AbaCXEo6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 00:44:58 -0400
In-Reply-To: <1395391278-19653-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Date: Fri, 21 Mar 2014 04:41:15 -0400

> This patch series containes following changes -
> 
> * TSO over IPv4 and IPv6, Tx checksum offload for VXLAN
> * Rx checksum offload for VXLAN and support for .ndo_{add|del}_vxlan_port
>   netdev ops.
> 
> Please apply this series to net-next.

Series applied, thank you.
