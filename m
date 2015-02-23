From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/4] net: bcmgenet: Tx init improvements
Date: Mon, 23 Feb 2015 17:46:05 -0500 (EST)
Message-ID: <20150223.174605.538476112763690957.davem@davemloft.net>
References: <20150223190045.EF567221256@puck.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: pgynther@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38670 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752905AbbBWWqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 17:46:07 -0500
In-Reply-To: <20150223190045.EF567221256@puck.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petri Gynther <pgynther@google.com>
Date: Mon, 23 Feb 2015 11:00:45 -0800 (PST)

> Four small patches to improve bcmgenet Tx init:
> 1. bcmgenet_init_tx_ring() cleanup
> 2. rework Tx queue init
> 3. precalculate TxCB->bd_addr
> 4. rename bcmgenet_hw_params->bds_cnt and GENET_DEFAULT_BD_CNT

Applied, thanks.
