From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-02-12
Date: Thu, 13 Feb 2014 18:17:56 -0500 (EST)
Message-ID: <20140213.181756.1724218328769353398.davem@davemloft.net>
References: <1392201340-6909-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1392201340-6909-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 12 Feb 2014 11:35:39 +0100

> this is a pull request with one patch for net/master, for the current release
> cycle. Olivier Sobrie noticed and fixed that the kvaser_usb driver doesn't
> check the number of channels value from the hardware, which may result in
> writing over the bounds of an array in the driver.

Pulled, thank you.
