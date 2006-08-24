From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/44] [XFRM] STATE: Search by address using source
 address list.
Date: Wed, 23 Aug 2006 17:56:29 -0700 (PDT)
Message-ID: <20060823.175629.35467754.davem@davemloft.net>
References: <11563453653851-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453653575-git-send-email-yoshfuji@linux-ipv6.org>
	<1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:56743
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965310AbWHXA40 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 20:56:26 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <1156345365651-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:07 +0900

> From: Masahide NAKAMURA <nakam@linux-ipv6.org>
> 
> This is a support to search transformation states by its addresses
> by using source address list for Mobile IPv6 usage.
> To use it from user-space, it is also added a message type for
> source address as a xfrm state option.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
