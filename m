From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: gigaset: use after free
Date: Sat, 07 Aug 2010 23:04:23 -0700 (PDT)
Message-ID: <20100807.230423.209957640.davem@davemloft.net>
References: <20100806082126.GT9031@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hjlipp@web.de, tilman@imap.cc, isdn@linux-pingi.de, tj@kernel.org,
	joe@perches.com, gigaset307x-common@lists.sourceforge.net,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59003
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750972Ab0HHGEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 02:04:04 -0400
In-Reply-To: <20100806082126.GT9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Fri, 6 Aug 2010 10:21:26 +0200

> I moved the kfree(cb) below the dereferences.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
