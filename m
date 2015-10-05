From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v1 0/8] amd-xgbe: AMD XGBE driver updates
 2015-09-30
Date: Mon, 05 Oct 2015 03:29:19 -0700 (PDT)
Message-ID: <20151005.032919.1714499250294207934.davem@davemloft.net>
References: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38827 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752565AbbJEKNl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 06:13:41 -0400
In-Reply-To: <20150930135232.12605.15604.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Wed, 30 Sep 2015 08:52:32 -0500

> The following patches are included in this driver update series:
> 
> - Remove unneeded semi-colon
> - Follow the DT/ACPI precedence used by the device_ APIs
> - Add ethtool support for getting and setting the msglevel
> - Add ethtool support error and debug messages
> - Simplify the hardware FIFO assignment calculations
> - Add receive buffer unavailable statistic
> - Use the device workqueue instead of the system workqueue
> - Remove the use of a link state bit
> 
> This patch series is based on net-next.

Series applied, thanks Tom.
