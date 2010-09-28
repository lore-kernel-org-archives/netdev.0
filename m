From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] pch_gbe: add header files
Date: Tue, 28 Sep 2010 10:34:38 -0700 (PDT)
Message-ID: <20100928.103438.193722403.davem@davemloft.net>
References: <20100928141823.8c61000e.sfr@canb.auug.org.au>
	<20100928095643.18c5020f.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	masa-korg@dsn.okisemi.com
To: randy.dunlap@oracle.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100928095643.18c5020f.randy.dunlap@oracle.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 28 Sep 2010 09:56:43 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build errors, more header files needed.
> 
> drivers/net/pch_gbe/pch_gbe_main.c:965: error: implicit declaration of function 'tcp_hdr'
> drivers/net/pch_gbe/pch_gbe_main.c:965: error: invalid type argument of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:968: error: invalid type argument of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:976: error: implicit declaration of function 'udp_hdr'
> drivers/net/pch_gbe/pch_gbe_main.c:976: error: invalid type argument of '->' (have 'int')
> drivers/net/pch_gbe/pch_gbe_main.c:980: error: invalid type argument of '->' (have 'int')
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
