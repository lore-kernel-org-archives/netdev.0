From: David Miller <davem@davemloft.net>
Subject: Re: [patch 0/6][NETNS][IPV6] ndisc, tcp, mcast per namespace
Date: Fri, 07 Mar 2008 11:17:10 -0800 (PST)
Message-ID: <20080307.111710.238985394.davem@davemloft.net>
References: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dlezcano@fr.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41301
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756305AbYCGTRJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2008 14:17:09 -0500
In-Reply-To: <20080307152638.854138982@mai.toulouse-stg.fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Lezcano <dlezcano@fr.ibm.com>
Date: Fri, 07 Mar 2008 16:26:38 +0100

> The patchset makes ndisc, tcp and multicast to be per namespace.
> At this point, it is possible to configure a namespace, communicate via
> udp6 or tcp6 to the outside world, or run a sshd daemon inside and connect
> to it.

All applied to net-2.6.26, thanks Daniel.
