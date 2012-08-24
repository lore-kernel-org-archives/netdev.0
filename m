From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2012-08-24
Date: Fri, 24 Aug 2012 15:21:48 -0400 (EDT)
Message-ID: <20120824.152148.1272042065601340498.davem@davemloft.net>
References: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1345800643-29456-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 24 Aug 2012 11:30:41 +0200

> here are two fixes for the v3.6 release cycle. Alexey Khoroshilov submitted a
> fix for a memory leak in the softing driver (in softing_load_fw()) in case a
> krealloc() fails. Sven Schmitt fixed the misuse of the IRQF_SHARED flag in the
> irq resouce of the sja1000 platform driver, now the correct flag is used. There
> are no mainline users of this feature which need to be converted.

Pulled, thanks Marc.
