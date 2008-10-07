From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] ipv6: making UDP mibs per/namespace
Date: Tue, 07 Oct 2008 15:00:19 -0700 (PDT)
Message-ID: <20081007.150019.143782024.davem@davemloft.net>
References: <1222942394.6327.5.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org, benjamin.thery@bull.net,
	dlezcano@fr.ibm.com, xemul@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51684
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754668AbYJGWAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2008 18:00:44 -0400
In-Reply-To: <1222942394.6327.5.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 02 Oct 2008 14:13:14 +0400

> This patch series provides a basic infrastructure to make snmp6
> statistics per/namespace and actually virtualize udp6/udplite6 mibs.
> 
> This set follows approach used by Pavel Emelyanov in IPv4 code.
> IP6/icmp6 statistics is also ready and will follow.

Applied and pushed out to net-next-2.6, thanks!
