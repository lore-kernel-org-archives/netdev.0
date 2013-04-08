From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mvmdio: get and enable optional clock
Date: Mon, 08 Apr 2013 16:56:50 -0400 (EDT)
Message-ID: <20130408.165650.1844719222601323138.davem@davemloft.net>
References: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: florian@openwrt.org, thomas.petazzoni@free-electrons.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: sebastian.hesselbarth@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1365332988-9053-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Date: Sun,  7 Apr 2013 13:09:47 +0200

> Marvell mdio driver uses internal registers that can be clock gated on
> some SoCs. This patch just adds optional clock handling, to allow to pass
> and enable the corresponding clock.
> 
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Applied.
