From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bcmgenet: Remove duplicate test for
 tx_coalesce_usecs_high
Date: Mon, 21 Sep 2015 16:26:40 -0700 (PDT)
Message-ID: <20150921.162640.116050809577556990.davem@davemloft.net>
References: <1442611013-9470-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, julia.lawall@lip6.fr, kbuild-all@01.org,
	jaedon.shin@gmail.com, pgynther@google.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56411 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752311AbbIUX0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Sep 2015 19:26:41 -0400
In-Reply-To: <1442611013-9470-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 18 Sep 2015 14:16:53 -0700

> We were checking twice for ec->tx_coalesce_usecs_high, remove the
> duplicate test.
> 
> Reported-by: Julia Lawall <julia.lawall@lip6.fr>
> Reported-by: kbuild-all@01.org
> Fixes: 2f9130709d2c19 ("net: bcmgenet: Implement TX coalescing control knobs")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
