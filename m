From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 12/12 net-2.6.26] [ICMP6]: Consolidate fail path
 icmpv6_sk_init with icmpv6_sk_exit.
Date: Fri, 29 Feb 2008 14:15:45 -0800 (PST)
Message-ID: <20080229.141545.53045112.davem@davemloft.net>
References: <1204292458-11636-12-git-send-email-den@openvz.org>
	<20080229.112342.76764059.davem@davemloft.net>
	<1204322741.7867.3.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55974
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761800AbYB2WPq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 17:15:46 -0500
In-Reply-To: <1204322741.7867.3.camel@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Sat, 01 Mar 2008 01:05:41 +0300

> Though, I have made a similar mistake in the IPv4 code. Pls consider
> the patch attached.

Applied and pushed out to net-2.6.26, thanks.
