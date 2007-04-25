From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PATCH] [net-2.6.22] IPv6, IPv4 Updates
Date: Wed, 25 Apr 2007 15:04:23 -0700 (PDT)
Message-ID: <20070425.150423.68036712.davem@davemloft.net>
References: <20070425.215521.118284577.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50086
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754357AbXDYWER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 18:04:17 -0400
In-Reply-To: <20070425.215521.118284577.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Wed, 25 Apr 2007 21:55:21 +0900 (JST)

> Please consider pulling following commits available on
> 	net-2.6.22-20070425a-inet6-cleanup-20070425
> branch at
> 	<git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-dev.git>.
> 
> HEADLINES
> ---------
> 
>     [IPV6] SIT: Unify code path to get hash array index.
>     [IPV4] IPIP: Unify code path to get hash array index.
>     [IPV4] IP_GRE: Unify code path to get hash array index.
>     [IPV6]: Export in6addr_any for future use.
>     [IPV6] XFRM: Use ip6addr_any where applicable.
>     [IPV6] NDISC: Unify main process of sending ND messages.

Pulled, thanks a lot!
