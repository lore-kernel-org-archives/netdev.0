From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2016-03-04
Date: Fri, 04 Mar 2016 14:33:35 -0500 (EST)
Message-ID: <20160304.143335.1222077020877144032.davem@davemloft.net>
References: <1457078155-8479-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1457078155-8479-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri,  4 Mar 2016 08:55:54 +0100

> Hello David,
> 
> this is a pull request for net/master.
> 
> There is one patch from Ed Spiridonov, which increases the performance of the
> mcp251x SPI CAN driver, by avoiding to write to error flag register if it's
> unnecessary.

Pulled, thanks.
