From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH][IPSEC][2/3] IPv6 over IPv4 IPsec tunnel
Date: Tue, 20 Feb 2007 01:13:24 -0800 (PST)
Message-ID: <20070220.011324.63128721.davem@davemloft.net>
References: <20061229144712.e154b021.kazunori@miyazawa.org>
	<200702101225.33939.nakam@linux-ipv6.org>
	<20070220.122432.796987476.takamiya@po.ntts.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, miika@iki.fi, Diego.Beltrami@hiit.fi,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org, nakam@linux-ipv6.org
To: takamiya@po.ntts.co.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35310
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750901AbXBTJN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 04:13:27 -0500
In-Reply-To: <20070220.122432.796987476.takamiya@po.ntts.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
Date: Tue, 20 Feb 2007 12:24:32 +0900 (JST)

>   More fix is needed for __xfrm6_bundle_create().
> 
> Signed-off-by: Noriaki TAKAMIYA <takamiya@po.ntts.co.jp>
> Acked-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
>   
> --------------------------------------------------
>   fixed to set fl_tunnel.fl6_src correctly in xfrm6_bundle_create().

Patch applied, thank you very much.
