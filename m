From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ethtool: use "ops" name consistenty in
 ethtool_set_rxfh()
Date: Sat, 21 Feb 2015 21:59:25 -0500 (EST)
Message-ID: <20150221.215925.91114669130700758.davem@davemloft.net>
References: <20150220105405.GC7895@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, amirv@mellanox.com, edumazet@google.com,
	VenkatKumar.Duvvuru@Emulex.Com, eswierk@skyportsystems.com,
	jiri@resnulli.us, _govind@gmx.com, eyalpe@mellanox.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150220105405.GC7895@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 20 Feb 2015 13:54:05 +0300

> "dev->ethtool_ops" and "ops" are the same, but we should use "ops"
> everywhere to be consistent.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied to net-next, thanks Dan.
