From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc: replace IS_ERR and PTR_ERR with PTR_ERR_OR_ZERO
Date: Thu, 07 Nov 2013 03:02:26 -0500 (EST)
Message-ID: <20131107.030226.60499118013736952.davem@davemloft.net>
References: <1383724637-15849-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kernel@pengutronix.de, linux@arm.linux.org.uk,
	a.zummo@towertech.it, airlied@linux.ie, dmitry.torokhov@gmail.com,
	axboe@kernel.dk, linux-kernel@vger.kernel.org,
	rtc-linux@googlegroups.com, dri-devel@lists.freedesktop.org,
	linux-tegra@vger.kernel.org, linux-input@vger.kernel.org,
	devel@driverdev.osuosl.org, netdev@vger.kernel.org
To: duanj.fnst@cn.fujitsu.com
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <1383724637-15849-1-git-send-email-duanj.fnst@cn.fujitsu.com>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Wed, 6 Nov 2013 15:57:17 +0800

> This patch fixes coccinelle error regarding usage of IS_ERR and
> PTR_ERR instead of PTR_ERR_OR_ZERO.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied.
