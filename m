From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: fix ks8851 build errors
Date: Wed, 19 Aug 2009 12:13:44 -0700 (PDT)
Message-ID: <20090819.121344.67683197.davem@davemloft.net>
References: <20090818152705.64557a0b.randy.dunlap@oracle.com>
	<20090818.201200.69809801.davem@davemloft.net>
	<20090819085202.810630a2.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	akpm@linux-foundation.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753077AbZHSTNf@vger.kernel.org>
In-Reply-To: <20090819085202.810630a2.randy.dunlap@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Wed, 19 Aug 2009 08:52:02 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Fix build errors due to missing Kconfig select of CRC32:
> 
> ks8851.c:(.text+0x7d2ee): undefined reference to `crc32_le'
> ks8851.c:(.text+0x7d2f5): undefined reference to `bitrev32'
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
