From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tproxy: check for transparent flag in ip_route_newports
Date: Mon, 27 Sep 2010 15:03:51 -0700 (PDT)
Message-ID: <20100927.150351.184847320.davem@davemloft.net>
References: <20100927133100.GB8916@babylon>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: uweber@astaro.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58076
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750865Ab0I0WDb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Sep 2010 18:03:31 -0400
In-Reply-To: <20100927133100.GB8916@babylon>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ulrich Weber <uweber@astaro.com>
Date: Mon, 27 Sep 2010 15:31:00 +0200

> as done in ip_route_connect()
> 
> Signed-off-by: Ulrich Weber <uweber@astaro.com>

Applied, thanks for fixing this.
