From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] arcnet: Collection of latest features
Date: Thu, 29 Jun 2017 15:26:52 -0400 (EDT)
Message-ID: <20170629.152652.1667234540243358841.davem@davemloft.net>
References: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44862 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751537AbdF2T04 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 15:26:56 -0400
In-Reply-To: <20170628163221.32301-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Wed, 28 Jun 2017 18:32:17 +0200

> Here we sum up the latest features to improve the arcnet framework. One
> patch is used to get feedback from the transfer queue about failed xfers
> by adding the err_skb message queue. Beside that we improve the
> backplane status that can be read by the PCI-based cards and offer that
> status via an extra sysfs attribute. In the last patch we add another
> card type PCIFB2.

Series applied, thanks.
