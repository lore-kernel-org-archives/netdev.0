From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3] IPv6: Add IPV6_RECVPATHMTU, IPV6_PATHMTU and
 IPV6_DONTFRAG support
Date: Fri, 23 Apr 2010 23:36:22 -0700 (PDT)
Message-ID: <20100423.233622.71122258.davem@davemloft.net>
References: <1272057969-6526-1-git-send-email-brian.haley@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38037
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750930Ab0DXGgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Apr 2010 02:36:17 -0400
In-Reply-To: <1272057969-6526-1-git-send-email-brian.haley@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 23 Apr 2010 17:26:06 -0400

> This series adds support for IPV6_RECVPATHMTU, IPV6_PATHMTU, and
> IPV6_DONTFRAG socket options as defined in RFC 3542.

Nice work, applied to net-next-2.6, thanks Brian!
