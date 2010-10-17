From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net/pch_gbe: Use
 DEFINE_PCI_DEVICE_TABLE
Date: Sun, 17 Oct 2010 13:51:16 -0700 (PDT)
Message-ID: <20101017.135116.39183656.davem@davemloft.net>
References: <1287086150.1117.608.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: masa-korg@dsn.okisemi.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1287086150.1117.608.camel@Joe-Laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Thu, 14 Oct 2010 12:55:50 -0700

> Use the standard macro to put this table in __devinitconst.
> 
> Compiled, untested.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
