From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-02-12
Date: Fri, 07 Mar 2014 17:10:50 -0500 (EST)
Message-ID: <20140307.171050.780817492945952823.davem@davemloft.net>
References: <5319954F.3080208@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <5319954F.3080208@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 07 Mar 2014 10:45:51 +0100

> this is a pull request of twelve patches for net-next/master.
> 
> Alexander Shiyan contributes two patches for the mcp251x, one making
> the driver more quiet and the other one improves the compile time
> coverage by removing the #ifdef CONFIG_PM_SLEEP. Then two patches for
> the flexcan driver by me, one removing the #ifdef CONFIG_PM_SLEEP, too,
> the other one making use of platform_get_device_id(). Another patch by
> me which converts the janz-ican3 driver to use netdev_<level>(). The
> remaining 7 patches are by Oliver Hartkopp, they add CAN FD support to
> the netlink configuration interface.
 ...
>   git://gitorious.org/linux-can/linux-can-next.git tags/linux-can-next-for-3.15-20140307

Pulled, thank you Marc.
