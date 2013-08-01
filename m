From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2013-08-01
Date: Thu, 01 Aug 2013 16:15:27 -0700 (PDT)
Message-ID: <20130801.161527.1594172734368232008.davem@davemloft.net>
References: <51FA4DD8.1040903@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <51FA4DD8.1040903@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 01 Aug 2013 14:00:24 +0200

> this is a pull-request for net-next/master. It consists of two patches
> by Fabio Estevam. Them first convert the flexcan driver to use
> devm_ioremap_resource(), the second adds return value checking for
> clk_prepare_enable().

Pulled, thanks Marc.
