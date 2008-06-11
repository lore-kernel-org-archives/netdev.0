From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] irda: remove CVS keywords
Date: Tue, 10 Jun 2008 22:48:18 -0700 (PDT)
Message-ID: <20080610.224818.94769506.davem@davemloft.net>
References: <20080519220221.GC17716@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42971
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755374AbYFKFsS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2008 01:48:18 -0400
In-Reply-To: <20080519220221.GC17716@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Tue, 20 May 2008 01:02:21 +0300

> This patch removes CVS keyword that weren't updated for a long time.
> 
> One of them was printed as part of a printk, which also doesn't make 
> much sense for a 5 year old and no longer updated keyword.
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Also applied to net-next-2.6, thanks.
