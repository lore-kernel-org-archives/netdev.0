From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4] net: cpsw: Add support for wake-on-lan for
 cpsw
Date: Tue, 20 Aug 2013 23:50:45 -0700 (PDT)
Message-ID: <20130820.235045.928210475401472997.davem@davemloft.net>
References: <1376978378-26096-1-git-send-email-ujhelyi.m@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ujhelyi.m@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376978378-26096-1-git-send-email-ujhelyi.m@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ujhelyi.m@gmail.com
Date: Tue, 20 Aug 2013 07:59:38 +0200

> From: Matus Ujhelyi <ujhelyi.m@gmail.com>
> 
> Some phy's can be configured to enable wake on lan (e.g. at803x or marvell 88E1318S).
> There is no way how to enable wol on CPSW with such connected phys. This patch
> adds this support. It is provided by calling the phy's related code.
> 
> Tested on board with at8030x connected phy. Wol interrupt line is
> connected to GPIO0 on am335x.
> 
> Signed-off-by: Matus Ujhelyi <ujhelyi.m@gmail.com>

Applied.
