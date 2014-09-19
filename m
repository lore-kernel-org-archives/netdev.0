From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-09-18
Date: Fri, 19 Sep 2014 17:34:48 -0400 (EDT)
Message-ID: <20140919.173448.2187577520178284616.davem@davemloft.net>
References: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1411036862-13255-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Thu, 18 Sep 2014 12:40:54 +0200

> this is a pull request of 8 patches for current net.
> 
> A patch by Roger Quadros for the c_can driver fixes the swapped parameters of
> the c_can_hw_raminit_ti() function. Oliver Hartkopp adds the missing PCI ids to
> the peak_pci driver to support the single channel PCAN ExpressCard 34 adapter.
> David Dueck converts the at91_can driver to use proper clock handling
> functions. Then there are 5 patches by David Jander and me which fix several
> mailbox related problems in the flexcan driver.

Pulled, thanks Marc.
