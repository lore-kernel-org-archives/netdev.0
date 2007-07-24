From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Netfilter Kconfig: Expose IPv4/6 connection tracking
 options by selecting NF_CONNTRACK
Date: Mon, 23 Jul 2007 22:48:36 -0700 (PDT)
Message-ID: <20070723.224836.55506536.davem@davemloft.net>
References: <200707240836.33494.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net@vger.kernel.org,
	sam@ravnborg.org, akpm@linux-foundation.org
To: a1426z@gawab.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55875
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755279AbXGXFsg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jul 2007 01:48:36 -0400
In-Reply-To: <200707240836.33494.a1426z@gawab.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Any reason you're not sending this to the netfilter developer list
mentioned in MAINTAINERS, or it's chief maintainer Patrick McHardy?

NETFILTER/IPTABLES/IPCHAINS
P:	Rusty Russell
P:	Marc Boucher
P:	James Morris
P:	Harald Welte
P:	Jozsef Kadlecsik
P:	Patrick McHardy
M:	kaber@trash.net
L:	netfilter-devel@lists.netfilter.org
L:	netfilter@lists.netfilter.org (subscribers-only)
L:	coreteam@netfilter.org
W:	http://www.netfilter.org/
W:	http://www.iptables.org/
S:	Supported

