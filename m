From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] RFC3484 Configurable Policy Table.
Date: Wed, 14 Nov 2007 01:52:51 -0800 (PST)
Message-ID: <20071114.015251.235076857.davem@davemloft.net>
References: <20071114.163728.134148765.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53232
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754713AbXKNJww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2007 04:52:52 -0500
In-Reply-To: <20071114.163728.134148765.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 14 Nov 2007 16:37:28 +0900 (JST)

> Please consider pulling from
> 	inet6-2.6.25
> branch at
> 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>
> which contains the following commits on top of your net-2.6.25 tree.
 ...
>     [IPV6] ADDRCONF: Rename ipv6_saddr_label() to ipv6_addr_label().
>     [IPV6] ADDRCONF: Allow address selection policy with ifindex.
>     [IPV6] ADDRCONF: Support RFC3484 configurable address selection policy table.

Pulled and pushed back out to net-2.6.25, thanks a lot!
