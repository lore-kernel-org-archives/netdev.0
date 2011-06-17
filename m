From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] be2net: fix netdev_stats_update()
Date: Thu, 16 Jun 2011 23:06:53 -0400 (EDT)
Message-ID: <20110616.230653.2259178543745778124.davem@davemloft.net>
References: <f67e2aac-b763-404d-8e45-5c5f52c56d18@exht1.ad.emulex.com>
	<1307947748.2872.182.camel@edumazet-laptop>
	<3367B80B08154D42A3B2BC708B5D41F63F18593D4F@EXMAIL.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: Sathya.Perla@Emulex.Com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754844Ab1FQDG7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:06:59 -0400
In-Reply-To: <3367B80B08154D42A3B2BC708B5D41F63F18593D4F@EXMAIL.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Sathya.Perla@Emulex.Com>
Date: Mon, 13 Jun 2011 00:09:38 -0700

> Dave, I would prefer to send a separate patch fixing the netdev
> stats issue after you apply this multiple TXQ patch. Are you OK with
> that?

Sure.
