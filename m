From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] net: bcmgenet: multiple Rx queues support
Date: Fri, 27 Mar 2015 14:26:40 -0700 (PDT)
Message-ID: <20150327.142640.143383028098812408.davem@davemloft.net>
References: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, jaedon.shin@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41446 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbbC0VSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Mar 2015 17:18:01 -0400
In-Reply-To: <20150325193509.09C362201FB@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Wed, 25 Mar 2015 12:35:08 -0700 (PDT)

> Final patch set to add support for multiple Rx queues:
> 1. remove priv->int0_mask and priv->int1_mask
> 2. modify Tx ring int_enable and int_disable vectors
> 3. simplify bcmgenet_init_dma()
> 4. tweak init_umac()
> 5. rework Tx NAPI code
> 6. rework Rx NAPI code
> 7. add support for multiple Rx queues

Series applied, thanks.
