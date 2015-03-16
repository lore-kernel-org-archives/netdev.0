From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: icn: use strlcpy() when parsing setup options
Date: Sun, 15 Mar 2015 22:26:08 -0400 (EDT)
Message-ID: <20150315.222608.153678214553500887.davem@davemloft.net>
References: <20150315104803.GA20691@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20150315104803.GA20691@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sun, 15 Mar 2015 13:48:03 +0300

> If you pass an invalid string here then you probably deserve the memory
> corruption, but it annoys static analysis tools so lets fix it.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
