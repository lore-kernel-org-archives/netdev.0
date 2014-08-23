From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2014-08-20
Date: Fri, 22 Aug 2014 19:43:06 -0700 (PDT)
Message-ID: <20140822.194306.1213839822576773356.davem@davemloft.net>
References: <53F4B580.3030802@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-can@vger.kernel.org,
	kernel@pengutronix.de
To: mkl@pengutronix.de
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <53F4B580.3030802@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Wed, 20 Aug 2014 16:49:36 +0200

> There is one patch by Wolfram Sang to clean up the build system.
> Two patches by Stefan Agner that add vf610 support to the flexcan
> driver. Dong Aisheng add support for bosch's m_can core, which is found
> in the new freescale ARM SoCs. Sergei Shtylyov improves the rcar_can
> driver by supporting all input clocks and adding device tree support.
> The next patch is a small cleanup for the bit rate calculation function
> by Lad, Prabhakar. And finally a patch by Himangi Saraogi, which
> converts the mcp251x driver to use dmam_alloc_coherent.

Pulled, thanks Marc.
