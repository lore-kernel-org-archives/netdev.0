From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH][NETNS]: Don't initialize err variable twice.
Date: Thu, 24 Apr 2008 01:14:45 +0900 (JST)
Message-ID: <20080424.011445.116982615.yoshfuji@linux-ipv6.org>
References: <480C91A9.4030004@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:33003 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbYDWQOr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2008 12:14:47 -0400
In-Reply-To: <480C91A9.4030004@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In article <480C91A9.4030004@openvz.org> (at Mon, 21 Apr 2008 17:07:53 +0400), Pavel Emelyanov <xemul@openvz.org> says:

> The ip6_route_net_init() performs some unneeded actions.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
