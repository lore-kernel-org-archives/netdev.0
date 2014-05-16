From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] net: systemport: DMA and MAC fixes
Date: Fri, 16 May 2014 16:42:56 -0400 (EDT)
Message-ID: <20140516.164256.57517920671590981.davem@davemloft.net>
References: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49167 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753048AbaEPUm6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2014 16:42:58 -0400
In-Reply-To: <1400189633-7602-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu, 15 May 2014 14:33:51 -0700

> This patch series contains a critical fix in how the DMA unmapping of packet
> is done, as well as a less critical fix in how we disable the Ethernet MAC
> RX/TX functions.

Series applied, thanks Florian.
