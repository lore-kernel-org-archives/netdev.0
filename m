From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/7] net: mvneta: Switch to per-CPU irq and make
 rxq_def useful
Date: Wed, 30 Sep 2015 08:40:39 -0700 (PDT)
Message-ID: <20150930.084039.1788742148434227487.davem@davemloft.net>
References: <1443197378-30717-1-git-send-email-gregory.clement@free-electrons.com>
	<20150929.115157.1923947727727463035.davem@davemloft.net>
	<alpine.DEB.2.11.1509301655140.4500@nanos>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregory.clement@free-electrons.com, jason@lakedaemon.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thomas.petazzoni@free-electrons.com, andrew@lunn.ch,
	sebastian.hesselbarth@gmail.com, alior@marvell.com,
	tawfik@marvell.com, nadavh@marvell.com,
	ezequiel.garcia@free-electrons.com,
	maxime.ripard@free-electrons.com,
	boris.brezillon@free-electrons.com, w@1wt.eu,
	linux-arm-kernel@lists.infradead.org
To: tglx@linutronix.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.11.1509301655140.4500@nanos>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Gleixner <tglx@linutronix.de>
Date: Wed, 30 Sep 2015 16:56:06 +0200 (CEST)

> On Tue, 29 Sep 2015, David Miller wrote:
>> From: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> Date: Fri, 25 Sep 2015 18:09:31 +0200
>> 
>> > As stated in the first version: "this patchset reworks the Marvell
>> > neta driver in order to really support its per-CPU interrupts, instead
>> > of faking them as SPI, and allow the use of any RX queue instead of
>> > the hardcoded RX queue 0 that we have currently."
>> 
>> Series applied, thanks.
> 
> You could have had the courtesy to wait for an ack for the core irq
> parts at least....

Sorry, my impression was that those parts were already discussed and
agreed upon.
