From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-10-31
Date: Mon, 04 Nov 2013 00:48:59 -0500 (EST)
Message-ID: <20131104.004859.1308706799176823597.davem@davemloft.net>
References: <1383247490-26984-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1383247490-26984-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 31 Oct 2013 20:24:48 +0100

> The first patch fixes a problem in the c_can's RX message handling, which can
> lead to an endless interrupt loop under heavy load if messages are lost. The
> second patch is by Olivier Sobrie and fixes the endpoint detection of the
> kvaser_usb driver, which is needed for some devices.

Pulled, thanks Marc.
