From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: phy: smsc: Fix disabling energy detect mode
Date: Thu, 21 Jan 2016 12:06:21 -0800 (PST)
Message-ID: <20160121.120621.312904386049504736.davem@davemloft.net>
References: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	linux-kernel@vger.kernel.org, andrew@lunn.ch
To: t.remmet@phytec.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453293635-6121-1-git-send-email-t.remmet@phytec.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Teresa Remmet <t.remmet@phytec.de>
Date: Wed, 20 Jan 2016 13:40:35 +0100

> When the lan87xx_read_status function is getting called the
> energy detect mode is enabled again even if it has been
> disabled by device tree.
> 
> Added private struct to check the energy detect status.
> 
> Signed-off-by: Teresa Remmet <t.remmet@phytec.de>

Applied, thanks.
