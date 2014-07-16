From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-07-15
Date: Tue, 15 Jul 2014 17:40:27 -0700 (PDT)
Message-ID: <20140715.174027.1724741587245396612.davem@davemloft.net>
References: <53C4DBD2.8010309@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53C4DBD2.8010309@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue, 15 Jul 2014 09:44:18 +0200

> this is a pull request of 4 patches for net-next/master.
> 
> Prabhakar Lad contributes a patch that converts the c_can driver to use
> the devm api. The remaining four patches by Nikita Edward Baruzdin
> improve the SJA1000 driver with loopback testing support and introduce
> a new testing mode presume ack, for successful transmission even if no
> ACK is received.

Pulled, thanks Marc.
