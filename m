From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix circular dependency in of_mdio code
Date: Fri, 27 Jun 2014 13:00:47 -0700 (PDT)
Message-ID: <20140627.130047.2048727601323698608.davem@davemloft.net>
References: <20140627.002626.309916119429166859.davem@davemloft.net>
	<20140627.124510.393574473550421757.davem@davemloft.net>
	<1c64f353-b695-481b-8ffb-bc1fa2f45bae@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffm@suse.com, f.fainelli@gmail.com, netdev@vger.kernel.org
To: daniel@zonque.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbaF0UAr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 16:00:47 -0400
In-Reply-To: <1c64f353-b695-481b-8ffb-bc1fa2f45bae@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Mack <daniel@zonque.org>
Date: Fri, 27 Jun 2014 21:57:16 +0200

> Ok, we need a stub for !CONFIG_OF_MDIO. I'll send a patch in a few
> hours. Is one that goes on top ok? Or do you want me to send an
> amended version of the last one?

I never pushed your patch out, I removed it from my tree, so you need to send
me a completely new change.
