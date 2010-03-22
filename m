From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 2/2] can: sja1000: add read/write routines
 for 8, 16 and 32-bit register access
Date: Sun, 21 Mar 2010 20:37:15 -0700 (PDT)
Message-ID: <20100321.203715.137820424.davem@davemloft.net>
References: <4BA356A4.5040205@visionsystems.de>
	<4BA35704.2060909@visionsystems.de>
	<20100320035639.GB26934@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yegor_sub1@visionsystems.de, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de
To: w.sang@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52901
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753949Ab0CVDgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 23:36:52 -0400
In-Reply-To: <20100320035639.GB26934@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfram Sang <w.sang@pengutronix.de>
Date: Sat, 20 Mar 2010 04:56:39 +0100

> On Fri, Mar 19, 2010 at 11:50:44AM +0100, Yegor Yefremov wrote:
>> SJA1000: add read/write routines for 8, 16 and 32-bit register access
>> 
>> add routines for 8, 16 and 32-bit access like in 
>> drivers/i2c/busses/i2c-pca-platform.c
>> 
>> Signed-off-by: Yegor Yefremov <yegorslists@googlemail.com>
> 
> Acked-by: Wolfram Sang <w.sang@pengutronix.de>

Applied.
