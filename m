From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/44] Mobile IPv6 Platform, Take 2 (for net-2.6.19)
Date: Wed, 23 Aug 2006 17:06:44 -0700 (PDT)
Message-ID: <20060823.170644.39159577.davem@davemloft.net>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:33469
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965317AbWHXAGm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:06:42 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:01 +0900

> we have another discussion about improvement of XFRM state hash.
> Our patches (about source address list part) will conflict with that
> work, but we did not take that into account so far because it was not
> in the tree.

Yes, do not worry about this.  I will add my changes later
after we integrate the mobile-ipv6 work, and therefore I will
take care of the conflicts.
