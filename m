From: David Miller <davem@davemloft.net>
Subject: Re: [patch] [AX.25]: small cleanup in ax25_addr_parse()
Date: Mon, 09 Jul 2012 00:16:34 -0700 (PDT)
Message-ID: <20120709.001634.1183046288317502958.davem@davemloft.net>
References: <20120705082718.GA14993@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ralf@linux-mips.org, linux-hams@vger.kernel.org,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <20120705082718.GA14993@elgon.mountain>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 5 Jul 2012 11:27:18 +0300

> The comments were wrong here because "AX25_MAX_DIGIS" is 8 but the
> comments say 6.  Also I've changed the "7" to "AX25_ADDR_LEN".
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
