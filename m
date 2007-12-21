From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] MIPv6: Fix to input RO state correctly.
Date: Thu, 20 Dec 2007 20:42:05 -0800 (PST)
Message-ID: <20071220.204205.101721158.davem@davemloft.net>
References: <11982084484155-git-send-email-nakam@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
To: nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36645
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754420AbXLUEmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 23:42:05 -0500
In-Reply-To: <11982084484155-git-send-email-nakam@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 21 Dec 2007 12:40:48 +0900

> Disable spin_lock during xfrm_type.input() function.
> Follow design as IPsec inbound does.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>

Applied.
