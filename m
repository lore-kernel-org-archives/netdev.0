From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: at803x: support interrupt on 8030 and 8035
Date: Mon, 16 Nov 2015 14:19:01 -0500 (EST)
Message-ID: <20151116.141901.1176705861586783809.davem@davemloft.net>
References: <1447350020-27969-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, slash.tmp@free.fr
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447350020-27969-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mans Rullgard <mans@mansr.com>
Date: Thu, 12 Nov 2015 17:40:20 +0000

> Commit 77a993942 "phy/at8031: enable at8031 to work on interrupt mode"
> added interrupt support for the 8031 PHY but left out the other two
> chips supported by this driver.
> 
> This patch sets the .ack_interrupt and .config_intr functions for the
> 8030 and 8035 drivers as well.
> 
> Signed-off-by: Mans Rullgard <mans@mansr.com>

Applied.
