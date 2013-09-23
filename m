From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/lapb: re-send packets on timeout
Date: Mon, 23 Sep 2013 16:53:25 -0400 (EDT)
Message-ID: <20130923.165325.1506033071596532414.davem@davemloft.net>
References: <1379498435-28860-1-git-send-email-josselin.costanzi@mobile-devices.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxime.jayat@mobile-devices.fr
To: josselin.costanzi@mobile-devices.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753742Ab3IWUx1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 16:53:27 -0400
In-Reply-To: <1379498435-28860-1-git-send-email-josselin.costanzi@mobile-devices.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Josselin Costanzi <josselin.costanzi@mobile-devices.fr>
Date: Wed, 18 Sep 2013 12:00:35 +0200

> Actually re-send packets when the T1 timer runs out. This fixes a bug
> where packets are waiting on the write queue until disconnection when
> no other traffic is outstanding.
> 
> Signed-off-by: Josselin Costanzi <josselin.costanzi@mobile-devices.fr>
> Signed-off-by: Maxime Jayat <maxime.jayat@mobile-devices.fr>

Applied, thanks.
