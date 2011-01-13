From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] bna: Remove unnecessary memset(,0,)
Date: Wed, 12 Jan 2011 19:01:01 -0800 (PST)
Message-ID: <20110112.190101.93384575.davem@davemloft.net>
References: <6f6d4a7a705949a3464471f364f77215f1e796f3.1294867098.git.joe@perches.com>
	<0ed96bd1a053e61c827f2ac09e38cba59e32a21b.1294867098.git.joe@perches.com>
	<E5313AF6F2BFD14293E5FD0F94750F86A5CFF6C4A8@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, ddutt@Brocade.COM, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: rmody@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34846
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932780Ab1AMDA3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jan 2011 22:00:29 -0500
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A5CFF6C4A8@HQ1-EXCH01.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>
Date: Wed, 12 Jan 2011 14:55:25 -0800

> 
>>From: Joe Perches [mailto:joe@perches.com]
>>Sent: Wednesday, January 12, 2011 1:21 PM
>>
>>kzalloc'd memory doesn't need a memset to 0.
>>
>>Signed-off-by: Joe Perches <joe@perches.com>
> 
> Acked-by: Rasesh Mody <rmody@brocade.com>

Applied.
