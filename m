From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] net: mvneta: Switch to per-CPU irq and make
 rxq_def useful
Date: Tue, 29 Sep 2015 11:51:57 -0700 (PDT)
Message-ID: <20150929.115157.1923947727727463035.davem@davemloft.net>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, jason@lakedaemon.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com, alior@marvell.com,
	tawfik@marvell.com, nadavh@marvell.com,
	ezequiel.garcia@free-electrons.com,
	maxime.ripard@free-electrons.com,
	boris.brezillon@free-electrons.com, w@1wt.eu,
	linux-arm-kernel@lists.infradead.org
To: gregory.clement@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57924 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935176AbbI2Sv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 14:51:58 -0400
In-Reply-To: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Date: Fri, 25 Sep 2015 18:09:31 +0200

> As stated in the first version: "this patchset reworks the Marvell
> neta driver in order to really support its per-CPU interrupts, instead
> of faking them as SPI, and allow the use of any RX queue instead of
> the hardcoded RX queue 0 that we have currently."

Series applied, thanks.
