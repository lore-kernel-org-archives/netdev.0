From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv4/IPv6: update sysctl files
Date: Wed, 08 Apr 2009 02:09:19 -0700 (PDT)
Message-ID: <20090408.020919.22840656.davem@davemloft.net>
References: <49DC19D5.7090101@cn.fujitsu.com>
	<20090408.001828.262566823.davem@davemloft.net>
	<49DC6569.5030908@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: shen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38576
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753306AbZDHJJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 05:09:29 -0400
In-Reply-To: <49DC6569.5030908@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shen Feng <shen@cn.fujitsu.com>
Date: Wed, 08 Apr 2009 16:50:49 +0800

> /proc/sys/net/ipv4/tcp_mem is a inet sysctl, but it also controls the tcp v6.
> So it's also a inet6 sysctl. Is it intentional?

Yes, please just drop this.
