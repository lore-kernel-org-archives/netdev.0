From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.20] [IPV6]: Repair IPv6 Fragments
Date: Tue, 05 Dec 2006 13:47:40 -0800 (PST)
Message-ID: <20061205.134740.02300095.davem@davemloft.net>
References: <20061205.182828.110151638.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kozakai@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758751AbWLEVrf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Dec 2006 16:47:35 -0500
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20061205.182828.110151638.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 05 Dec 2006 18:28:28 +0900 (JST)

> Hello.
> 
> The commit "[IPV6]: Use kmemdup" (commit-id:
> af879cc704372ef762584e916129d19ffb39e844) broke IPv6 fragments.
> 
> Bug was spotted by Yasuyuki Kozakai <yasuyuki.kozakai@toshiba.co.jp>.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Thank you for catching and fixing this bug, patch applied.
