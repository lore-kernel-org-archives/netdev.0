From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] CAN: add controller hardware name for Softing cards
Date: Mon, 28 Feb 2011 12:09:00 -0800 (PST)
Message-ID: <20110228.120900.183054389.davem@davemloft.net>
References: <20110221090421.GF328@e-circ.dyndns.org>
	<4D622CC1.5050402@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kurt.van.dijck@eia.be, netdev@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753927Ab1B1UIY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Feb 2011 15:08:24 -0500
In-Reply-To: <4D622CC1.5050402@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 21 Feb 2011 10:13:37 +0100

> On 02/21/2011 10:04 AM, Kurt Van Dijck wrote:
>> I just found that the controller hardware name is not set for the Softing
>> driver. After this patch, "$ ip -d link show" looks nicer.
>> 
>> Signed-off-by: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

Applied, thanks.
