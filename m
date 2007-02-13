From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][0/4] fix conflict of device tunnels with the
 ipsec tunnel
Date: Tue, 13 Feb 2007 13:54:14 -0800 (PST)
Message-ID: <20070213.135414.30185805.davem@davemloft.net>
References: <20070209163716.eb7ced2c.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, miika@iki.fi, Diego.Beltrami@hiit.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52958
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751220AbXBMVyQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Feb 2007 16:54:16 -0500
In-Reply-To: <20070209163716.eb7ced2c.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Fri, 9 Feb 2007 16:37:16 +0900

> [1/4] changing API of xfrm4_tunnel_register
> [2/4] make sit use the xfrm4_tunnel_register
> [3/4] changing API of xfrm6_tunnel_register
> [4/4] Fix the address family to refer encap_family

I've applied all 4 patches, thank you.
