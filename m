From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/3] Add support emac for the RK3036 SoC platform
Date: Sun, 10 Jan 2016 22:21:51 -0500 (EST)
Message-ID: <20160110.222151.599769321034656161.davem@davemloft.net>
References: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, heiko@sntech.de, netdev@vger.kernel.org,
	paul.gortmaker@windriver.com, linux-kernel@vger.kernel.org,
	geert@linux-m68k.org, linux-arm-kernel@lists.infradead.org
To: zhengxing@rock-chips.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452216902-21063-1-git-send-email-zhengxing@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xing Zheng <zhengxing@rock-chips.com>
Date: Fri,  8 Jan 2016 09:34:59 +0800

>   We have supported the emac for RK3066/RK3188, but the RK3036 have
> some configuration different with them. We should let the driver of
> emac_rockchip compatible with other Rockchip SoCs.

Series applied to net-next.
