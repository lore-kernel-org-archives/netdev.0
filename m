From: David Miller <davem@davemloft.net>
Subject: Re: Latest version of zero-copy fix
Date: Mon, 10 Feb 2014 17:48:17 -0800 (PST)
Message-ID: <20140210.174817.515546870536354612.davem@davemloft.net>
References: <20140210.152150.574073124161003333.davem@davemloft.net>
	<52F97D5F.4040100@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ryao@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57497 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190AbaBKBsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Feb 2014 20:48:19 -0500
In-Reply-To: <52F97D5F.4040100@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Yao <ryao@gentoo.org>
Date: Mon, 10 Feb 2014 20:31:11 -0500

> 1. We allocate a temporary buffer with vmalloc().
> 2. We read the module into that buffer.

Ok, I didn't catch this, I'll apply your patch thanks!
