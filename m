From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: ax88796: support generating a
 random mac address
Date: Fri, 26 May 2017 14:58:01 -0400 (EDT)
Message-ID: <20170526.145801.234438629971913647.davem@davemloft.net>
References: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43590 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754253AbdEZS6D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 14:58:03 -0400
In-Reply-To: <20170525205511.22048-1-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>
Date: Thu, 25 May 2017 22:55:11 +0200

> Instead of falling back to 00:00:00:00:00:00 generate a random address
> if none is provided via platform data or from the the device's register
> space.
> 
> Signed-off-by: Uwe Kleine-König <u.kleine-koenig@pengutronix.de>

Applied.
