From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] mv643xx_eth: calculate descriptor pointer only
 once in rxq_refill()
Date: Thu, 20 Nov 2008 03:59:42 -0800 (PST)
Message-ID: <20081120.035942.110949848.davem@davemloft.net>
References: <20081118223028.GX5006@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: buytenh@wantstofly.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42757
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754254AbYKTL7m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 06:59:42 -0500
In-Reply-To: <20081118223028.GX5006@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Tue, 18 Nov 2008 23:30:29 +0100

> Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Applied.
