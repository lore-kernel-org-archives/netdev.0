From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8*/ksz8*: Casting (void *) value returned by kmalloc
 is useless
Date: Mon, 21 Nov 2011 15:06:48 -0500 (EST)
Message-ID: <20111121.150648.1335802022965214612.davem@davemloft.net>
References: <1321569820.1624.248.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: thomas@m3y3r.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1321569820.1624.248.camel@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Meyer <thomas@m3y3r.de>
Date: Thu, 17 Nov 2011 23:43:40 +0100

> The semantic patch that makes this change is available
> in scripts/coccinelle/api/alloc/drop_kmalloc_cast.cocci.
> 
> Signed-off-by: Thomas Meyer <thomas@m3y3r.de>

Applied.
