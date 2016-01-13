From: David Miller <davem@davemloft.net>
Subject: Re: [patch] mlxsw: fix SWITCHDEV_OBJ_ID_PORT_MDB
Date: Wed, 13 Jan 2016 10:35:29 -0500 (EST)
Message-ID: <20160113.103529.1906079275568373739.davem@davemloft.net>
References: <20160113122823.GD19993@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, eladr@mellanox.com, idosch@mellanox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160113122823.GD19993@mwanda>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Wed, 13 Jan 2016 15:28:23 +0300

> There is a missing break statement so we always return -EOPNOTSUPP.
> 
> Fixes: 3a49b4fde2a1 ('mlxsw: Adding layer 2 multicast support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
