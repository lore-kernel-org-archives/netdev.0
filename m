From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: dmfe: Remove old log spamming pr_debugs
Date: Mon, 18 Jul 2011 10:45:37 -0700 (PDT)
Message-ID: <20110718.104537.546991191560526229.davem@davemloft.net>
References: <201107181440.35886.jdelvare@suse.de>
	<0a5f6c4c4c948dd5ff827bb5c5517294c9410bfc.1311000440.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jdelvare@suse.de, grundler@parisc-linux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43567 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab1GRRpq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 13:45:46 -0400
In-Reply-To: <0a5f6c4c4c948dd5ff827bb5c5517294c9410bfc.1311000440.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Mon, 18 Jul 2011 07:50:33 -0700

> Commit 726b65ad444d ("tulip: Convert uses of KERN_DEBUG") enabled
> some old previously inactive uses of pr_debug converted by
> commit dde7c8ef1679 ("tulip/dmfe.c: Use dev_<level> and pr_<level>").
> 
> Remove these pr_debugs.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied.
