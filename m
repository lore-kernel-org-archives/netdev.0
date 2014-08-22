From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-08-21
Date: Thu, 21 Aug 2014 21:53:39 -0700 (PDT)
Message-ID: <20140821.215339.1016944928830108729.davem@davemloft.net>
References: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1408613002-29693-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 21 Aug 2014 11:23:18 +0200

> The first patch is from Mirza Krak, it fixes the initialization of the hardware
> in the sja1000 driver. The next patch is contributed by Dan Carpenter, it fixes
> the error handling in the c_can's probe function. Then there are two patches
> for the flexcan driver, one by Alexander Stein, which fixes the resetting of
> the bus error interrupt mask, the other one by Sebastian Andrzej Siewior which
> adds an additional error state transition message.

Pulled, thanks Marc.
