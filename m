From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-04-25
Date: Sat, 26 Apr 2014 12:33:09 -0400 (EDT)
Message-ID: <20140426.123309.1445855723743499773.davem@davemloft.net>
References: <53598E72.30504@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53598E72.30504@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 25 Apr 2014 00:21:38 +0200

> this is a pull request of 10 patches for net-next/master.
> 
> It consists of three patches by Alexander Shiyan, which improve the
> mcp251x driver. Stefano Babic's patch move the SPI driver into a sub
> folder. The three patches by Olivier Sobrie add support for the Kvaser
> Leaf v2 and usb mini PCIe hardware to the existing driver. Alexander
> Stein contributes eg20t support to the c_can pci driver. Together with
> the patches on the net-tree, we'll be able to remove the pch_can driver
> soon. Kurt Van Dijck's two patches clean up the sysfs attributes of the
> softing driver.

Pulled, thank you.
