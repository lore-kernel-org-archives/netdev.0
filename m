From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] [XFRM]: Define packet dropping statistics.
Date: Thu, 20 Dec 2007 20:43:15 -0800 (PST)
Message-ID: <20071220.204315.203486139.davem@davemloft.net>
References: <11982085132010-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38317
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754382AbXLUEnQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:43:16 -0500
In-Reply-To: <11982085132010-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 21 Dec 2007 12:41:53 +0900

> This statistics is shown factor dropped by transformation
> at /proc/net/xfrm_stat for developer.
> It is a counter designed from current transformation source code
> and defined as linux private MIB.
> 
> See Documentation/networking/xfrm_proc.txt for the detail.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Patch applied.

This is very useful, thanks for implementing this feature.
