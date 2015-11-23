From: David Miller <davem@davemloft.net>
Subject: Re: [patch] net/hsr: fix a warning message
Date: Mon, 23 Nov 2015 14:56:36 -0500 (EST)
Message-ID: <20151123.145636.1037248055461936030.davem@davemloft.net>
References: <20151121103412.GF7002@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arvid.brodin@alten.se, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20151121103412.GF7002@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 21 Nov 2015 13:34:12 +0300

> WARN_ON_ONCE() takes a condition, it doesn't take an error message.  I
> have converted this to WARN() instead.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
