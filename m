From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] Exporting IPv6 statistics via netlink.
Date: Fri, 20 Apr 2007 22:15:27 -0700 (PDT)
Message-ID: <20070420.221527.32062470.davem@davemloft.net>
References: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41480
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754505AbXDUFPY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2007 01:15:24 -0400
In-Reply-To: <20070419.154209.131781981.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Thu, 19 Apr 2007 15:42:09 +0900 (JST)

>     [IPV6] SNMP: Netlink interface.
>     [IPV6] SNMP: Move some statistic bits to net/ipv6/proc.c.
>     [IPV4] SNMP: Move some statistic bits to net/ipv4/proc.c.

I applied these as patches to my net-2.6.22 tree.

Thanks.
