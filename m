From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2 v2] net: bcmgenet: TX reclaim and DMA fixes
Date: Mon, 22 Sep 2014 18:39:43 -0400 (EDT)
Message-ID: <20140922.183943.104495150444696692.davem@davemloft.net>
References: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754901AbaIVWjs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 18:39:48 -0400
In-Reply-To: <1411412083-9370-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon, 22 Sep 2014 11:54:41 -0700

> This patch set contains one fix for an accounting problem while reclaiming
> transmitted buffers having fragments, and the second fix is to make sure
> that the DMA shutdown is properly controlled.

Series applied, but I can't see how you could have possibly
functionally tested the original patch series if it didn't
even compile :-/
