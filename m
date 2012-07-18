From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v2] net: various tilegx networking fixes
Date: Wed, 18 Jul 2012 11:36:23 -0700 (PDT)
Message-ID: <20120718.113623.984635805289135415.davem@davemloft.net>
References: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37115 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755445Ab2GRSgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 14:36:23 -0400
In-Reply-To: <201207181650.q6IGodZ7007565@lab-41.internal.tilera.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Sun, 1 Jul 2012 14:43:47 -0400

> The tree is at:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/cmetcalf/linux-tile.git net
> 
> Chris Metcalf (3):
>       net: tilegx driver bugfix (be explicit about percpu queue number)
>       tilegx net driver: handle payload data not in frags
>       tilegx net: use eth_hw_addr_random(), not random_ether_addr()

These changes look fine, but when I pull from your tree I get tons of
totally unrelated stuff and a merge conflict in this driver.

Can you put together a clean pull against net-next?

Thanks.
