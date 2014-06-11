From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: realtek: register/unregister multiple
 drivers properly
Date: Wed, 11 Jun 2014 15:17:50 -0700 (PDT)
Message-ID: <20140611.151750.163707451871716166.davem@davemloft.net>
References: <1402372212-19553-1-git-send-email-neidhard.kim@lge.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, r58129@freescale.com,
	linux-kernel@vger.kernel.org
To: neidhard.kim@lge.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402372212-19553-1-git-send-email-neidhard.kim@lge.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jongsung Kim <neidhard.kim@lge.com>
Date: Tue, 10 Jun 2014 12:50:12 +0900

> Using phy_drivers_register/_unregister functions is proper way to
> handle multiple PHY drivers registration. For Realtek PHY drivers
> module, it fixes incomplete current error-handlings up and adds
> missed unregistration for the RTL8201CP driver.
> 
> Signed-off-by: Jongsung Kim <neidhard.kim@lge.com>

Applied, thank you.
