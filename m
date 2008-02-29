From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] unexport ip6_find_1stfragopt
Date: Thu, 28 Feb 2008 21:27:45 -0800 (PST)
Message-ID: <20080228.212745.214413003.davem@davemloft.net>
References: <20080222195811.GC1409@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36489
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751292AbYB2F1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 00:27:45 -0500
In-Reply-To: <20080222195811.GC1409@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Fri, 22 Feb 2008 21:58:11 +0200

> This patch removes the no longer used 
> EXPORT_SYMBOL_GPL(ip6_find_1stfragopt).
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>

Applied to net-2.6.26, thanks.
