From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.19] [IPV6]: Fix address/interface handling in UDP
 and DCCP, according to the scoping architecture.
Date: Tue, 21 Nov 2006 17:37:57 -0800 (PST)
Message-ID: <20061121.173757.130237988.davem@davemloft.net>
References: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:63363
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1161722AbWKVBh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Nov 2006 20:37:58 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061121.014306.76909112.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 21 Nov 2006 01:43:06 +0900 (JST)

> [IPV6]: Fix address/interface handling in UDP and DCCP, according to the scoping architecture.
> 
> TCP and RAW do not have this issue.  Closes Bug #7432.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks a lot!
