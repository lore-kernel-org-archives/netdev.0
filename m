From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL v2] ARCNET: code simplification and features
Date: Mon, 26 Oct 2015 22:23:45 -0700 (PDT)
Message-ID: <20151026.222345.1606847197716793544.davem@davemloft.net>
References: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35776 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbbJ0FHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 01:07:06 -0400
In-Reply-To: <1445847800-13975-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Mon, 26 Oct 2015 09:23:14 +0100

> This series includes code simplifaction. The main changes are the correct
> xceiver handling (enable/disable) of the com20020 cards. The driver now handles
> link status change detection. The EAE PCI-ARCNET cards now make use of the
> rotary encoded subdevice indexing and got support for led triggers on transmit
> and reconnection events.

Pulled, thanks Michael.
