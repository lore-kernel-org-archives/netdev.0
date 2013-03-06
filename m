From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix new kernel-doc warnings in net core
Date: Tue, 05 Mar 2013 23:56:20 -0500 (EST)
Message-ID: <20130305.235620.1048477356760189481.davem@davemloft.net>
References: <5135210B.6090207@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, torvalds@linux-foundation.org
To: rdunlap@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60837 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab3CFE4W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Mar 2013 23:56:22 -0500
In-Reply-To: <5135210B.6090207@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <rdunlap@infradead.org>
Date: Mon, 04 Mar 2013 14:32:43 -0800

> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Fix new kernel-doc warnings in net/core/dev.c:
> 
> Warning(net/core/dev.c:4788): No description found for parameter 'new_carrier'
> Warning(net/core/dev.c:4788): Excess function parameter 'new_carries' description in 'dev_change_carrier'
> 
> Signed-off-by: Randy Dunlap <rdunlap@infradead.org>

Applied, thanks Randy.
