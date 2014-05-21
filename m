From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-05-19
Date: Wed, 21 May 2014 02:01:23 -0400 (EDT)
Message-ID: <20140521.020123.2281089614429142140.davem@davemloft.net>
References: <5379B6CE.60004@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46117 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751066AbaEUGBY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 02:01:24 -0400
In-Reply-To: <5379B6CE.60004@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 19 May 2014 09:46:22 +0200

> this is a pull request of 13 patches for net-next/master.
> 
> A patch by Dan Carpenter fixes a coccinelle warning in the mcp251x
> driver. Jean Delvare contributes three patches to tightening the
> Kconfig dependencies for some drivers. Then come three patches by Pavel
> Machek that improve the c_can driver support on the socfpga platform.
> Sergei Shtylyov's patch brings support for the CAN hardware found on
> Renesas R-Car CAN controllers. Four patches by Oliver Hartkopp, the
> first cleans up the guard macros in the CAN headers the other three
> improve the EFF frame filtering. Maximilian Schneider's patch adds
> support for the GS_USB CAN devices.

Pulled, thank you.
