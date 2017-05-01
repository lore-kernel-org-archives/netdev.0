From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: Allow BCM5481x PHYs to setup internal TX/RX
 clock delay
Date: Sun, 30 Apr 2017 22:56:47 -0400 (EDT)
Message-ID: <20170430.225647.1704817458991201009.davem@davemloft.net>
References: <1493530461-11935-1-git-send-email-abhishek.shah@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
        bcm-kernel-feedback-list@broadcom.com
To: abhishek.shah@broadcom.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1493530461-11935-1-git-send-email-abhishek.shah@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Abhishek Shah <abhishek.shah@broadcom.com>
Date: Sun, 30 Apr 2017 11:04:21 +0530

> This patch allows users to enable/disable internal TX and/or RX
> clock delay for BCM5481x series PHYs so as to satisfy RGMII timing
> specifications.
> 
> On a particular platform, whether TX and/or RX clock delay is required
> depends on how PHY connected to the MAC IP. This requirement can be
> specified through "phy-mode" property in the platform device tree.
> 
> Signed-off-by: Abhishek Shah <abhishek.shah@broadcom.com>

Applied.
