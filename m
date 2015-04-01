From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2015-04-01
Date: Wed, 01 Apr 2015 13:58:55 -0400 (EDT)
Message-ID: <20150401.135855.1493925445705357780.davem@davemloft.net>
References: <551BC2C0.5000408@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <551BC2C0.5000408@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 01 Apr 2015 12:04:48 +0200

> this is a pull request of 5 patches for net-next/master.
> 
> There are two patches for the ems_usb driver by Gerhard Uttenthaler and
> me, which fix sparse endianess warnings. Oliver Hartkopp adds two
> patches to improve and extend the CAN-ID filter handling on RAW CAN
> sockets. The last patch is by me, it silences an uninitialized variable
> warning in the peak_usb driver.

Pulled, thanks Marc.
