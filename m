From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/6] can: remove double include, add support for
 various PEAK hardare
Date: Sun, 04 Mar 2012 22:02:45 -0500 (EST)
Message-ID: <20120304.220245.232415488930711083.davem@davemloft.net>
References: <1330794015-14930-1-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1330794015-14930-1-git-send-email-mkl@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Sat,  3 Mar 2012 18:00:09 +0100

> this patch series targets net-next. The first patch by Danny Kukawka
> removes a double include from the cc770 driver. The 5 remaining patches by
> Stephane Grosjean add support for various PEAK hardware:
> - PCAN-PCIeC (PCI-ExpressCard)
> - PCAN-mminiPCI (mini-PCI)
> - PCAN-PCI (PCI next-gen)
> - PCAN-PC Card (PCMCIA)
> - PCAN-USB
> - PCAN-USB Pro

Pulled, thanks a lot.
