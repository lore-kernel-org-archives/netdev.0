From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-01-29
Date: Thu, 30 Jan 2014 16:49:16 -0800 (PST)
Message-ID: <20140130.164916.449452740498509673.davem@davemloft.net>
References: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1391029863-23099-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 29 Jan 2014 22:11:00 +0100

> this is a pull request with three fixes for net/master, for the current release
> cycle.
> 
> Arnd Bergmann provides a fix for the flexcan driver, enabling compilation on
> all combinations of big and little endian on ARM and PowerPc. A patch by Ira W.
> Snyder fixes uninitialized variable warnings in the janz-ican3 driver.
> Rostislav Lisovy contributes a patch to propagate the SO_PRIORITY of raw
> sockets to skbs.

Pulled, thanks Marc.
