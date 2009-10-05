From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 21/21] drivers/net/tlan.h: Convert printk(KERN_DEBUG to
 pr_dbg(
Date: Mon, 05 Oct 2009 14:28:49 -0700
Message-ID: <1254778129.1799.591.camel@Joe-Laptop.home>
References: <cover.1254701151.git.joe@perches.com>
	 <20091005.001240.111554671.davem@davemloft.net>
	 <1254726974.1799.315.camel@Joe-Laptop.home>
	 <200910052315.01357.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	chessman@tux.org, netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754924AbZJEV32@vger.kernel.org>
In-Reply-To: <200910052315.01357.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2009-10-05 at 23:15 +0200, Rafael J. Wysocki wrote:
> Why don't you push the first patch first, then, and wait with the others until
> it gets merged?  This way individual subsystem maintainers will be able to
> merge them cleanly.

Sometimes patch series get a bit more feedback than individual patches.

Original rfc suggestion: (1 comment)
http://lkml.org/lkml/2009/10/1/399

Patch removing pr_fmt from driver (acked by Jiri):
http://lkml.org/lkml/2009/10/1/418

cheers, Joe
