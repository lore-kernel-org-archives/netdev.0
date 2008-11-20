From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: fix per-slice rx/tx_dropped counters
Date: Thu, 20 Nov 2008 01:50:13 -0800 (PST)
Message-ID: <20081120.015013.229192420.davem@davemloft.net>
References: <49232150.4010202@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41041
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753245AbYKTJuN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 04:50:13 -0500
In-Reply-To: <49232150.4010202@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Tue, 18 Nov 2008 21:10:56 +0100

> Properly attribute transmit and receive drops by incrementing the
> per-slice counter.
> 
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied.
