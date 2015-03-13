From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/2] net: bcmgenet: xmit_more support
Date: Fri, 13 Mar 2015 15:52:59 -0400 (EDT)
Message-ID: <20150313.155259.576019477409693769.davem@davemloft.net>
References: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, jaedon.shin@gmail.com,
	pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754053AbbCMTxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 15:53:00 -0400
In-Reply-To: <1426273867-10874-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 13 Mar 2015 12:11:05 -0700

> This patch series adds xmit_more support to the GENET driver by allowing
> the deferal of the producer index write to the TDMA engine.
> 
> Changes in v2:
> 
> - move the netif_tx_stop_queue check *before* updating the producer index

Series applied, thanks Florian.
