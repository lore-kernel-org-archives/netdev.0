From: David Miller <davem@davemloft.net>
Subject: Re: [patch] 6lowpan: release device on error path
Date: Thu, 07 Nov 2013 19:13:31 -0500 (EST)
Message-ID: <20131107.191331.5561975057667792.davem@davemloft.net>
References: <20131107074445.GD21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, alan@signal11.us,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20131107074445.GD21844@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 7 Nov 2013 10:44:45 +0300

> We recently added a new error path and it needs a dev_put().
> 
> Fixes: 7adac1ec8198 ('6lowpan: Only make 6lowpan links to IEEE802154 devices')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
