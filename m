From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/2] net: emac: fix reset timeout with AR8035 phy
Date: Thu, 08 Jun 2017 10:47:51 -0400 (EDT)
Message-ID: <20170608.104751.1757616937161373909.davem@davemloft.net>
References: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ivan@de.ibm.com, russell@personaltelco.net,
        andrew@lunn.ch, chrisrblake93@gmail.com
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57492 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbdFHOry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 10:47:54 -0400
In-Reply-To: <eefbc6df06c83b725c60997fc58cf1c0119334a1.1496773338.git.chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Wed,  7 Jun 2017 15:51:15 +0200

> This patch fixes a problem where the AR8035 PHY can't be
> detected on an Cisco Meraki MR24, if the ethernet cable is
> not connected on boot.
 ...
> Cc: Chris Blake <chrisrblake93@gmail.com>
> Reported-by: Russell Senior <russell@personaltelco.net>
> Fixes: 23fbb5a87c56e98 ("emac: Fix EMAC soft reset on 460EX/GT")
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Applied.
