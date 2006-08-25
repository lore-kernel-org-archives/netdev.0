From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 44/44] [XFRM] IPV6: Support Mobile IPv6 extension
 headers sorting.
Date: Fri, 25 Aug 2006 15:47:17 -0700 (PDT)
Message-ID: <20060825.154717.38711346.davem@davemloft.net>
References: <44EECBB0.7070001@linux-ipv6.org>
	<20060825.031651.88475974.davem@davemloft.net>
	<20060825232819.66C6.NAKAM@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30146
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751079AbWHYWrM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 18:47:12 -0400
To: nakam@linux-ipv6.org
In-Reply-To: <20060825232819.66C6.NAKAM@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Date: Fri, 25 Aug 2006 23:29:05 +0900

> Thank you for providing it quickly.
> It works! 

Thank you for testing.  I have pushed this bug fix into the
net-2.6.19 tree.
