From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 0/7] net: mvneta: Switch to per-CPU irq and make
 rxq_def useful
Date: Wed, 30 Sep 2015 16:56:06 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1509301655140.4500@nanos>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com> <20150929.115157.1923947727727463035.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: gregory.clement@free-electrons.com, jason@lakedaemon.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com, alior@marvell.com,
	tawfik@marvell.com, nadavh@marvell.com,
	ezequiel.garcia@free-electrons.com,
	maxime.ripard@free-electrons.com,
	boris.brezillon@free-electrons.com, w@1wt.eu,
	linux-arm-kernel@lists.infradead.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38616 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751015AbbI3O4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 10:56:47 -0400
In-Reply-To: <20150929.115157.1923947727727463035.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 29 Sep 2015, David Miller wrote:
> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Date: Fri, 25 Sep 2015 18:09:31 +0200
> 
> > As stated in the first version: "this patchset reworks the Marvell
> > neta driver in order to really support its per-CPU interrupts, instead
> > of faking them as SPI, and allow the use of any RX queue instead of
> > the hardcoded RX queue 0 that we have currently."
> 
> Series applied, thanks.

You could have had the courtesy to wait for an ack for the core irq
parts at least....
