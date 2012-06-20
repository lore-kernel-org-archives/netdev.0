From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: c_can_pci: limit compilation to archs with clock
 support
Date: Wed, 20 Jun 2012 03:12:06 -0700 (PDT)
Message-ID: <20120620.031206.460765333579696071.davem@davemloft.net>
References: <1340185688-9454-1-git-send-email-mkl@pengutronix.de>
	<20120620.025452.2203668280120884694.davem@davemloft.net>
	<4FE1A1A1.3000105@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	federico.vaga@gmail.com
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4FE1A1A1.3000105@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 20 Jun 2012 12:10:41 +0200

> I think we finally can see the big picture now; I'm preparing a patch
> which removes the clk_*() functions.

Thank you.
