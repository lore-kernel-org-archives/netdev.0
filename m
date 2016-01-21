From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvneta: fix trivial cut-off issue in
 mvneta_ethtool_update_stats
Date: Thu, 21 Jan 2016 12:04:16 -0800 (PST)
Message-ID: <20160121.120416.2119682070903117194.davem@davemloft.net>
References: <1453278985-6433-1-git-send-email-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: thomas.petazzoni@free-electrons.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rmk+kernel@arm.linux.org.uk
To: jszhang@marvell.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453278985-6433-1-git-send-email-jszhang@marvell.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jisheng Zhang <jszhang@marvell.com>
Date: Wed, 20 Jan 2016 16:36:25 +0800

> When s->type is T_REG_64, the high 32bits are lost in val. This patch
> fixes this trivial issue.
> 
> Signed-off-by: Jisheng Zhang <jszhang@marvell.com>
> Fixes: 9b0cdefa4cd5 ("net: mvneta: add ethtool statistics")

Applied.
