From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pppoe: drop PPPOX_ZOMBIEs in pppoe_flush_dev
Date: Wed, 06 Apr 2011 14:05:03 -0700 (PDT)
Message-ID: <20110406.140503.233687123.davem@davemloft.net>
References: <20110404123324.GA12662@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40626
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754768Ab1DFVFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:05:40 -0400
In-Reply-To: <20110404123324.GA12662@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Mon, 4 Apr 2011 14:33:24 +0200

> otherwise we loop forever if a PPPoE socket was set
> to PPPOX_ZOMBIE state by a PADT message when the
> ethernet device is going down afterwards.
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Applied, thanks Ulrich.
