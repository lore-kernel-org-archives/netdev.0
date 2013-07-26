From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: sun4i-emac: select MDIO_SUN4I
Date: Fri, 26 Jul 2013 13:58:21 -0700 (PDT)
Message-ID: <20130726.135821.1562114212326650459.davem@davemloft.net>
References: <1374649928-26007-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: maxime.ripard@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374649928-26007-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Maxime Ripard <maxime.ripard@free-electrons.com>
Date: Wed, 24 Jul 2013 09:12:08 +0200

> The EMAC driver can't work without its associated PHY driver. Reflect
> this in the Kconfig options by selecting it.
> 
> Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>

Applied.
