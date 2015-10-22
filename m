From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] ARCNET: code simplification and features
Date: Wed, 21 Oct 2015 18:37:51 -0700 (PDT)
Message-ID: <20151021.183751.1656152603570952326.davem@davemloft.net>
References: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49655 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327AbbJVBVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:21:25 -0400
In-Reply-To: <1445442332-10625-1-git-send-email-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Wed, 21 Oct 2015 17:45:26 +0200

> This series includes code simplifaction. The main changes are the correct
> xceiver handling (enable/disable) of the com20020 cards. The driver now handles
> link status change detection. The EAE PCI-ARCNET cards now make use of the
> rotary encoded subdevice indexing and got support for led triggers on transmit
> and reconnection events.

Please fix the problems found by the kbuild test robot, thanks.
