From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2013-02-01
Date: Sat, 02 Feb 2013 23:10:34 -0500 (EST)
Message-ID: <20130202.231034.2185119506799907924.davem@davemloft.net>
References: <1359710714-1565-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1359710714-1565-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri,  1 Feb 2013 10:25:13 +0100

> here's a patch for net for the v3.8 release cycle. Alexander Stein
> noticed that the c_can hardware has a fixed bit in the IFx_MASK2
> register. His patch fixes writing of this register by always setting
> this bit.

Pulled, thanks Marc.
