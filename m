From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: bcmgenet: device stats are unsigned long
Date: Sat, 16 Apr 2016 22:04:04 -0400 (EDT)
Message-ID: <20160416.220404.1649748037362161952.davem@davemloft.net>
References: <1460742472.10638.78.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37792 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073AbcDQCEG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Apr 2016 22:04:06 -0400
In-Reply-To: <1460742472.10638.78.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Apr 2016 10:47:52 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> On 64bit kernels, device stats are 64bit wide, not 32bit.
> 
> Fixes: 1c1008c793fa4 ("net: bcmgenet: add main driver file")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Eric.
