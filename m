From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 1/1 net-next] fec: net: put tx to napi poll function
 to fix dead lock
Date: Fri, 01 Mar 2013 03:37:32 -0500 (EST)
Message-ID: <20130301.033732.2050436929173088609.davem@davemloft.net>
References: <1362109034-25805-1-git-send-email-Frank.Li@freescale.com>
	<CANg6MZiQTPkWDBRiZB74nVrj-QY2=Nis36fvhv1Cj+p=jzOstA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Frank.Li@freescale.com, lznuaa@gmail.com, shawn.guo@linaro.org,
	B38611@freescale.com, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, s.hauer@pengutronix.de
To: linuxzsc@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54058 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758Ab3CAIhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Mar 2013 03:37:36 -0500
In-Reply-To: <CANg6MZiQTPkWDBRiZB74nVrj-QY2=Nis36fvhv1Cj+p=jzOstA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Zhao <linuxzsc@gmail.com>
Date: Fri, 1 Mar 2013 16:30:05 +0800

> Is it better to change title prefix to net: fec: ..... ?

I'm aiming to put it into 'net' regardless of what title prefix he
uses :-)
