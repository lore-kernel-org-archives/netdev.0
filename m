From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the tip tree
Date: Tue, 15 Sep 2015 21:53:40 -0700 (PDT)
Message-ID: <20150915.215340.1773903719174815221.davem@davemloft.net>
References: <20150916113053.21c217ce@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com,
	peterz@infradead.org, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	oneukum@suse.com
To: sfr@canb.auug.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56565 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbbIPExn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 00:53:43 -0400
In-Reply-To: <20150916113053.21c217ce@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Wed, 16 Sep 2015 11:30:53 +1000

> I have added the following fix patch for today:
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Wed, 16 Sep 2015 11:10:16 +1000
> Subject: [PATCH] cdc: add header guards
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks Stephen.
