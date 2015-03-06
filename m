From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: bcmgenet: preparation for multiple
 Rx queues
Date: Fri, 06 Mar 2015 15:14:44 -0500 (EST)
Message-ID: <20150306.151444.1533902822259577764.davem@davemloft.net>
References: <20150306014008.DDA6C2214B6@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55681 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbbCFUOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:14:47 -0500
In-Reply-To: <20150306014008.DDA6C2214B6@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Thu,  5 Mar 2015 17:40:08 -0800 (PST)

> Three small patches in preparation for supporting multiple Rx queues:
> 1. set hw_params->rx_queues = 0
> 2. adjust the call to alloc_etherdev_mqs()
> 3. add GENET_Q16_RX_BD_CNT and hw_params->rx_bds_per_q

Series applied, thanks.
