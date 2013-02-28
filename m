From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] r8169: honor jumbo settings when chipset is
 requested to start.
Date: Thu, 28 Feb 2013 15:39:53 -0500 (EST)
Message-ID: <20130228.153953.535569326042504902.davem@davemloft.net>
References: <20130227230157.GA30053@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomimo@ncircle.nullnet.fi,
	hayeswang@realtek.com
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47884 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726Ab3B1Uj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2013 15:39:56 -0500
In-Reply-To: <20130227230157.GA30053@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 28 Feb 2013 00:01:57 +0100

> Some hardware start settings implicitely assume an usual 1500 bytes mtu
> that can't be guaranteed because changes of mtu may be requested both
> before and after the hardware is started.
> 
> Reported-by: Tomi Orava <tomimo@ncircle.nullnet.fi>
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Applied.
