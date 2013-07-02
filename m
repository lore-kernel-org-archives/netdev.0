From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] xen-netback: xenbus.c: use more current
 logging styles
Date: Tue, 02 Jul 2013 00:53:12 -0700 (PDT)
Message-ID: <20130702.005312.1003541936812161241.davem@davemloft.net>
References: <1372720134-9765-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xen.org, netdev@vger.kernel.org,
	ian.campbell@citrix.com, joe@perches.com
To: wei.liu2@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab3GBHxN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 03:53:13 -0400
In-Reply-To: <1372720134-9765-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu <wei.liu2@citrix.com>
Date: Tue, 2 Jul 2013 00:08:54 +0100

> Convert one printk to pr_<level>.
> 
> Add a missing newline in several places to avoid message interleaving,
> coalesce formats, reflow modified lines to 80 columns.
> 
> Signed-off-by: Joe Perches <joe@perches.com>
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Applied, thanks.
