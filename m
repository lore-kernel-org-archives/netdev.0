From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: ipv6_addr_type() doesn't know about RFC4193
 addresses
Date: Thu, 26 Jul 2007 13:37:10 -0500 (CDT)
Message-ID: <20070726.133710.12677267.yoshfuji@linux-ipv6.org>
References: <18087.57717.495366.413571@zeus.sw.starentnetworks.com>
	<20070725.171203.102545287.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: djohnson+linux-kernel@sw.starentnetworks.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net,
	sakkiped@starentnetworks.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:49329 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934429AbXGZSgS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jul 2007 14:36:18 -0400
In-Reply-To: <20070725.171203.102545287.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20070725.171203.102545287.davem@davemloft.net> (at Wed, 25 Jul 2007 17:12:03 -0700 (PDT)), David Miller <davem@davemloft.net> says:

> Contrarily, there may be ipv6_addr_type() call sites that really
> do want to reject rfc4193 addresses.

I do not think we have such users.

--yoshfuji
