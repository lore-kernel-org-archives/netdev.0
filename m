From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] arcnet: Collection of latest fixes
Date: Thu, 29 Jun 2017 15:19:44 -0400 (EDT)
Message-ID: <20170629.151944.2253431382191653533.davem@davemloft.net>
References: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44736 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751605AbdF2TTq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:19:46 -0400
In-Reply-To: <20170628162837.21856-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Wed, 28 Jun 2017 18:28:32 +0200

> Here we sum up the recent fixes I collected on the way to use and
> stabilise the framework. Part of it is an possible deadlock that we
> prevent as well to fix the calculation of the dev_id that can be setup
> by an rotary encoder. Beside that we added an trivial spelling patch and
> fix some wrong and missing assignments that improves the code footprint.

Series applied, thanks.
