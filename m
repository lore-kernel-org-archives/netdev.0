From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2 v2] Add support of multicast static tree
Date: Mon, 21 Jan 2013 13:56:14 -0500 (EST)
Message-ID: <20130121.135614.1026114228632820099.davem@davemloft.net>
References: <OF894319C2.8EF01FDC-ON87257AFA.004BC5D6-85257AFA.004E0255@us.ibm.com>
	<1358784026-4071-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlstevens@us.ibm.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41077 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752755Ab3AUS4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 13:56:16 -0500
In-Reply-To: <1358784026-4071-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 21 Jan 2013 17:00:24 +0100

> The goal of this serie is to add the support of proxy multicast, ie being able
> to build a static multicast tree. In other words, it adds the support of (*,G)
> mf[6]c entries.
> 
> v2: use INADDR_ANY instead of 0 for IPv4 addresses

I'll apply this, thanks Nicolas.
