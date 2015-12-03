From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] via-rhine: fix VLAN receive handling
 regression.
Date: Thu, 03 Dec 2015 15:11:49 -0500 (EST)
Message-ID: <20151203.151149.1469916595946372476.davem@davemloft.net>
References: <20130807003431.GD16410@order.stressinduktion.org>
	<EF96A1CB-549E-474A-AF58-10F2D2F2BF4A@inf-net.nl>
	<CABAB3EF-4A65-4534-AE27-D9B069CAB0F7@inf-net.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrej@ota.si, netdev@vger.kernel.org
To: teco@inf-net.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45458 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479AbbLCULu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 15:11:50 -0500
In-Reply-To: <CABAB3EF-4A65-4534-AE27-D9B069CAB0F7@inf-net.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Teco Boot <teco@inf-net.nl>
Date: Wed, 2 Dec 2015 10:55:40 +0100

> I faced this problem on 4.2.6, Debian Jessie, on PC Engines Alix6. 
> I applied the patch. It solved the problem.
> 
> Queue up for -stable?

Done.
