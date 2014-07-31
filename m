From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] amd-xgbe: AMD XGBE driver update
 2014-07-25
Date: Wed, 30 Jul 2014 18:48:08 -0700 (PDT)
Message-ID: <20140730.184808.404820283176806159.davem@davemloft.net>
References: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: thomas.lendacky@amd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38355 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752288AbaGaBsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2014 21:48:09 -0400
In-Reply-To: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Lendacky <thomas.lendacky@amd.com>
Date: Tue, 29 Jul 2014 08:57:08 -0500

> This patch series is dependent on the following patch that was
> applied to the net tree and needs to be applied to the net-next
> tree:
>   332cfc823d18 - amd-xgbe: Fix error return code in xgbe_probe()
> 
> The following series of patches includes fixes and new support in the
> driver.
> 
> - Device bindings documentation update
> - Hardware timestamp support
> - 2.5GbE support changes
> - Fifo sizes based on active queues/rings
> - Phylib driver updates for:
>   - Rate change completion check
>   - KR training initiation
>   - Auto-negotiation results
> - Traffic class support, including DCB support
> 
> This patch series is based on net-next.
> 
> Changes in V2:
>   - Remove DBGPR(...., __func__) calls

Series applied, thanks Tom.
