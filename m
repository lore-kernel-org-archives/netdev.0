From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-sysfs: use to_net_dev in net_namespace()
Date: Tue, 22 Dec 2015 15:04:29 -0500 (EST)
Message-ID: <20151222.150429.2154037685806906363.davem@davemloft.net>
References: <d010715aeba7ecc4421b06b20f19c1f3958772db.1450796865.git.geliangtang@163.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, jiri@mellanox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geliangtang@163.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d010715aeba7ecc4421b06b20f19c1f3958772db.1450796865.git.geliangtang@163.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geliang Tang <geliangtang@163.com>
Date: Tue, 22 Dec 2015 23:11:49 +0800

> Use to_net_dev() instead of open-coding it.
> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>

Applied to net-next, thanks.
