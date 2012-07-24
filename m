From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wanmain: comparing array with NULL
Date: Tue, 24 Jul 2012 13:57:43 -0700 (PDT)
Message-ID: <20120724.135743.1872104730848217808.davem@davemloft.net>
References: <20120724181622.27921.80598.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755876Ab2GXU5o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2012 16:57:44 -0400
In-Reply-To: <20120724181622.27921.80598.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 24 Jul 2012 19:16:25 +0100

> From: Alan Cox <alan@linux.intel.com>
> 
> gcc really should warn about these !
> 
> Signed-off-by: Alan Cox <alan@linux.intel.com>

Applied and queued up for -stable.

> +		printk(KERN_INFO "%s: registering interface %s...\n",
>  				wanrouter_modname, dev->name);

I adjusted the indentation of the second line, as needed.
