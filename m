From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net/cadence/macb: add support for dt phy definition
Date: Mon, 26 Aug 2013 16:04:50 -0400 (EDT)
Message-ID: <20130826.160450.2176892065062148718.davem@davemloft.net>
References: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, rob.herring@calxeda.com,
	pawel.moll@arm.com, mark.rutland@arm.com, swarren@wwwdotorg.org,
	ian.campbell@citrix.com, linux@arm.linux.org.uk,
	f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	devicetree@vger.kernel.org
To: b.brezillon@overkiz.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1377186980-21902-1-git-send-email-b.brezillon@overkiz.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Boris BREZILLON <b.brezillon@overkiz.com>
Date: Thu, 22 Aug 2013 17:56:20 +0200

> This patch series adds support for ethernet phy definition using device
> tree.
> 
> This may help in moving some at91 boards to dt (some of them define an
> interrupt pin).
> 
> Tested on samad31ek.

Series applied to net-next, thanks.
