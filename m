From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [IPV6]: Return correct result for sticky options.
Date: Thu, 08 Mar 2007 20:47:59 -0800 (PST)
Message-ID: <20070308.204759.53337060.davem@davemloft.net>
References: <20070309.101152.77796563.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46801
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2992968AbXCIEr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 23:47:58 -0500
In-Reply-To: <20070309.101152.77796563.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 09 Mar 2007 10:11:52 +0900 (JST)

> We returned incorrect result with IPV6_RTHDRDSTOPTS, IPV6_RTHDR and
> IPV6_DSTOPTS.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
