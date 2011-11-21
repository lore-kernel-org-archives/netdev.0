From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net, sja1000: Don't include version.h in peak_pci.c
 when not needed
Date: Mon, 21 Nov 2011 16:44:21 -0500 (EST)
Message-ID: <20111121.164421.2285321515989917691.davem@davemloft.net>
References: <alpine.LNX.2.00.1111202204480.17195@swampdragon.chaosbits.net>
	<4ECA1F13.4080204@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jj@chaosbits.net, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	wg@grandegger.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4ECA1F13.4080204@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 21 Nov 2011 10:51:15 +0100

> On 11/20/2011 10:07 PM, Jesper Juhl wrote:
>> It was pointed out by "make versioncheck" that we do not need to include
>> version.h in drivers/net/can/sja1000/peak_pci.c
>> This patch removes the unneeded include.
>> 
>> Signed-off-by: Jesper Juhl <jj@chaosbits.net>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thanks everyone.
