From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport dev_ethtool
Date: Tue, 14 Aug 2007 17:39:00 -0700 (PDT)
Message-ID: <20070814.173900.85417650.davem@davemloft.net>
References: <20070814212203.GV18945@stusta.de>
	<20070814212325.GW16277@parisc-linux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@kernel.org, netdev@vger.kernel.org
To: matthew@wil.cx
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48593
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756060AbXHOAjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 20:39:01 -0400
In-Reply-To: <20070814212325.GW16277@parisc-linux.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Matthew Wilcox <matthew@wil.cx>
Date: Tue, 14 Aug 2007 15:23:26 -0600

> On Tue, Aug 14, 2007 at 11:22:03PM +0200, Adrian Bunk wrote:
> > This patch removes the no longer used EXPORT_SYMBOL(dev_ethtool).
> > 
> > Signed-off-by: Adrian Bunk <bunk@kernel.org>
> Acked-by: Matthew Wilcox <matthew@wil.cx>

Applied, thanks.
