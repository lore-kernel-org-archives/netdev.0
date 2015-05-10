From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mdio-gpio: Allow for unspecified bus id
Date: Sun, 10 May 2015 19:42:25 -0400 (EDT)
Message-ID: <20150510.194225.771601505981493819.davem@davemloft.net>
References: <1431094729-21775-1-git-send-email-bert@biot.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bert@biot.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1431094729-21775-1-git-send-email-bert@biot.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bert Vermeulen <bert@biot.com>
Date: Fri,  8 May 2015 16:18:49 +0200

> When the bus id was supplied via a struct platform_device, the driver wasn't
> handling -1 to mean an unspecified id of the only instance of this driver,
> as the platform spec requires.
> 
> Signed-off-by: Bert Vermeulen <bert@biot.com>

Applied, thanks.
