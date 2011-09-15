From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] net/can/af_can.c: Change del_timer to
 del_timer_sync
Date: Thu, 15 Sep 2011 15:07:54 -0400 (EDT)
Message-ID: <20110915.150754.210033389479791558.davem@davemloft.net>
References: <1314784658-23938-1-git-send-email-rajan.aggarwal85@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: socketcan@hartkopp.net, urs.thuermann@volkswagen.de,
	netdev@vger.kernel.org
To: rajan.aggarwal85@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47166 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934458Ab1IOTKC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2011 15:10:02 -0400
In-Reply-To: <1314784658-23938-1-git-send-email-rajan.aggarwal85@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rajan Aggarwal <rajan.aggarwal85@gmail.com>
Date: Wed, 31 Aug 2011 15:27:38 +0530

> From: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>
> 
> This is important for SMP platform to check if timer function is
> executing on other CPU with deleting the timer.
> 
> Signed-off-by: Rajan Aggarwal <Rajan Aggarwal rajan.aggarwal85@gmail.com>

Applied, thanks.
