From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/44] [IPV6]: Find option offset by type.
Date: Wed, 23 Aug 2006 19:18:50 -0700 (PDT)
Message-ID: <20060823.191850.107683292.davem@davemloft.net>
References: <11563453662840-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453662913-git-send-email-yoshfuji@linux-ipv6.org>
	<11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anttit@tcs.hut.fi, vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:22189
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030202AbWHXCSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 22:18:47 -0400
To: yoshfuji@linux-ipv6.org
In-Reply-To: <11563453663400-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Thu, 24 Aug 2006 00:02:23 +0900

> This is a helper to search option offset from extension header which
> can carry TLV option like destination options header.
> Mobile IPv6 home address option will use it.
> Based on MIPL2 kernel patch.
> 
> Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied to net-2.6.19, thanks a lot.
