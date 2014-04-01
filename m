From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can 2014-04-01
Date: Tue, 01 Apr 2014 17:50:16 -0400 (EDT)
Message-ID: <20140401.175016.1630099465882973166.davem@davemloft.net>
References: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1396388550-23081-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Tue,  1 Apr 2014 23:42:14 +0200

> this is a pull request of 16 patches for the 3.15 release cycle.
> 
> Bjorn Van Tilt contributes a patch which fixes a memory leak in usb_8dev's
> usb_8dev_start_xmit()s error path. A patch by Robert Schwebel fixes a typo in
> the can documentation. The remaining patches all target the c_can driver. Two
> of them are by me; they add a missing netif_napi_del() and return value
> checking. Thomas Gleixner contributes 12 patches, which address several
> shortcomings in the driver like hardware initialisation, concurrency, message
> ordering and poor performance.

Pulled, thanks Marc.
