From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] hippi: fix printk format in rrunner.c
Date: Mon, 16 Apr 2012 23:48:27 -0400 (EDT)
Message-ID: <20120416.234827.1041224459359020201.davem@davemloft.net>
References: <20120416161121.261ba4e7e38989173accfb16@canb.auug.org.au>
	<4F8CC0ED.2000006@xenotime.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-hippi@sunsite.dk, jes@trained-monkey.org,
	akpm@linux-foundation.org
To: rdunlap@xenotime.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F8CC0ED.2000006@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <rdunlap@xenotime.net>
Date: Mon, 16 Apr 2012 18:01:33 -0700

> From: Randy Dunlap <rdunlap@xenotime.net>
> 
> Fix printk format warning (from i386 build):
> 
> drivers/net/hippi/rrunner.c:146:9: warning: format '%08llx' expects type 'long long unsigned int', but argument 3 has type 'resource_size_t'
> 
> Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>

I'll apply this, thanks Randy.
