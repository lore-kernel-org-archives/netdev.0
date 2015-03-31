From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/5] net: bcmgenet: code cleanup
Date: Tue, 31 Mar 2015 14:15:19 -0400 (EDT)
Message-ID: <20150331.141519.720581396582411470.davem@davemloft.net>
References: <20150330072835.0E1EB220215@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49241 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753202AbbCaSPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Mar 2015 14:15:21 -0400
In-Reply-To: <20150330072835.0E1EB220215@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon, 30 Mar 2015 00:28:34 -0700 (PDT)

> Five patches to clean up bcmgenet code:
> 1. add UMAC_IRQ_RXDMA_DONE and UMAC_IRQ_TXDMA_DONE
> 2. remove __bcmgenet_fini_dma()
> 3. fix bcmgenet_open()
> 4. add UMAC_IRQ_LINK_EVENT
> 5. fix the call to phy_mac_interrupt()

Series applied, thank you.
