From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: emaclite: Not necessary to call devm_iounmap
Date: Fri, 20 Sep 2013 14:41:14 -0400 (EDT)
Message-ID: <20130920.144114.821790857141050930.davem@davemloft.net>
References: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, monstr@monstr.eu, renner@efe-gmbh.de,
	libo.chen@huawei.com, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org
To: michal.simek@xilinx.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <196d8368eee2d45eeeab40e96e2971f78ed8a79b.1378969499.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Simek <michal.simek@xilinx.com>
Date: Thu, 12 Sep 2013 09:05:10 +0200

> devm_iounmap is called automatically.
> 
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

Applied to net-next
