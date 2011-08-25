From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] be2net fixes v2
Date: Wed, 24 Aug 2011 17:08:13 -0700 (PDT)
Message-ID: <20110824.170813.2053302439438184017.davem@davemloft.net>
References: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sathya.perla@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47425 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915Ab1HYAIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Aug 2011 20:08:18 -0400
In-Reply-To: <1314078115-8121-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sathya Perla <sathya.perla@emulex.com>
Date: Tue, 23 Aug 2011 11:11:50 +0530

> Incorporated Eric's feedback on [3/5] be2net: fix erx->rx_drops_no_frags wrap around
> Pls apply. Thanks.
> 
> Sathya Perla (5):
>   be2net: Fix race in posting rx buffers.
>   be2net: get rid of memory mapped pci-cfg space address
>   be2net: fix erx->rx_drops_no_frags wrap around
>   be2net: increase FW update completion timeout
>   be2net: remove unused variable

Series applied, thanks.
