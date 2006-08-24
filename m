From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 30/44] [XFRM] STATE: Add Mobile IPv6 route optimization
 protocols to netlink interface.
Date: Wed, 23 Aug 2006 20:33:59 -0700 (PDT)
Message-ID: <20060823.203359.124553836.davem@davemloft.net>
References: <11563453674049-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453673517-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453674137-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:59818
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030249AbWHXDd4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 23:33:56 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453674137-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:31 +0900

> Add Mobile IPv6 route optimization protocols to netlink interface.
> Route optimization states carry care-of address.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks.
