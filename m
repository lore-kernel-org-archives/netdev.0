From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/11] net/ariadne: Improve debug prints
Date: Wed, 21 Mar 2012 22:16:10 -0400 (EDT)
Message-ID: <20120321.221610.1111479562922750614.davem@davemloft.net>
References: <1332323515-7314-1-git-send-email-geert@linux-m68k.org>
	<1332323515-7314-9-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-m68k@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48764 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916Ab2CVCRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 22:17:18 -0400
In-Reply-To: <1332323515-7314-9-git-send-email-geert@linux-m68k.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 21 Mar 2012 10:51:53 +0100

> Remove casts and use proper printf()-style format specifiers instead.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

You can merge these in via the m68k tree if you want.

Acked-by: David S. Miller <davem@davemloft.net>
