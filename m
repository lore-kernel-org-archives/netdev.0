From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] cxgb3: move away from LLTX
Date: Fri, 29 May 2009 01:57:47 -0700 (PDT)
Message-ID: <20090529.015747.109057209.davem@davemloft.net>
References: <20090529075823.30669.28885.stgit@speedy5>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757085AbZE2I5r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 04:57:47 -0400
In-Reply-To: <20090529075823.30669.28885.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>
Date: Fri, 29 May 2009 00:58:24 -0700

> From: Divy Le Ray <divy@chelsio.com>
> 
> cxgb3 no longer advertizes LLTX.
> 
> Signed-off-by: Divy Le Ray <divy@chelsio.com>

You might want to mention that these two patches depend
upon the 2.6.30 cxgb3 patches you also submitted at this
time and aren't in the tree yet. :-/

