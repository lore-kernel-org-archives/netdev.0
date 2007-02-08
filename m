From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][IPSEC][0/6] fix conflict of device tunnels with the
 ipsec tunnel
Date: Thu, 08 Feb 2007 13:09:28 -0800 (PST)
Message-ID: <20070208.130928.07640160.davem@davemloft.net>
References: <20070208170324.3e3a4d59.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, miika@iki.fi, Diego.Beltrami@hiit.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
To: kazunori@miyazawa.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38917
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1423353AbXBHVJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Feb 2007 16:09:29 -0500
In-Reply-To: <20070208170324.3e3a4d59.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Date: Thu, 8 Feb 2007 17:03:24 +0900

> I send patches to fix conflict of device tunnels with the inter
> address family ipsec tunnel. Yoshifuji-san and Kozakai-san
> noticed me of the confliction.
> 
> I adopt same approach of tunnel4.c and tunnel6.c. I extend them
> to support inter address family.
> 
> We need this to use ipcomp with inter address family tunnel.

Please fixup the issues reported by Patrick McHardy, thank you.
