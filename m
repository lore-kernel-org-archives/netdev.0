From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 0/4] enic: updates to version 2.1.1.20
Date: Thu, 09 Jun 2011 14:58:39 -0700 (PDT)
Message-ID: <20110609.145839.189371419853732891.davem@davemloft.net>
References: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: vkolluri@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756423Ab1FIV6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2011 17:58:40 -0400
In-Reply-To: <20110609203620.31838.61879.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>
Date: Thu, 09 Jun 2011 13:36:46 -0700

> The following series implements enic driver updates:
> 
> 1/4 - Pass 802.1p bits for packets tagged with vlan zero
> 2/4 - Change log message during driver load
> 3/4 - Get/Set interrupt resource index for transmit and receive queues
> 4/4 - Bug Fix: Fix hardware transmit queue indexing in enic_poll_controller
> 
> Signed-off-by: Christian Benvenuti <benve@cisco.com>
> Signed-off-by: Danny Guo <dannguo@cisco.com>
> Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
> Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
> Signed-off-by: David Wang <dwang2@cisco.com>

All applied, thank you.
