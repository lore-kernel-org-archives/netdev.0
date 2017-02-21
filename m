From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dpaa_eth: implement ioctl() for PHY-related ops
Date: Mon, 20 Feb 2017 22:21:53 -0500 (EST)
Message-ID: <20170220.222153.1822889903577152992.davem@davemloft.net>
References: <1487606058-10994-1-git-send-email-michael@walle.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: madalin.bucur@nxp.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: michael@walle.cc
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487606058-10994-1-git-send-email-michael@walle.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Walle <michael@walle.cc>
Date: Mon, 20 Feb 2017 16:54:18 +0100

> This commit adds the ndo_do_ioctl() callback which allows the userspace to
> access PHY registers, for example. This will make mii-diag and similar
> tools work.
> 
> Signed-off-by: Michael Walle <michael@walle.cc>

Applied, thanks.
