From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-04-24
Date: Sat, 26 Apr 2014 12:31:55 -0400 (EDT)
Message-ID: <20140426.123155.1657644162899113586.davem@davemloft.net>
References: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398376829-6771-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Fri, 25 Apr 2014 00:00:03 +0200

> this is a pull request for net/master, for the v3.15 release cycle, consisting
> of 26 patches.
> 
> Thomas Gleixner contributes 21 patches for the c_can driver, which address
> several shortcomings in the driver like hardware initialisation, concurrency,
> message ordering and poor performance. Two patches Oliver Hartkopp, one adds a
> missing lock to the sja1000_isa driver, the other one fixes the return value in
> the generic bit time configuration function. And finally a patch by Alexander
> Stein, that fixes the slcan driver to use the correct spinlock variant.

Pulled, thanks.
