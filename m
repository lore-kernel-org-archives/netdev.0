From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] make netlink processing routines semi-synchronious
 (inspired by rtnl) v2
Date: Wed, 10 Oct 2007 21:13:40 -0700 (PDT)
Message-ID: <20071010.211340.130233951.davem@davemloft.net>
References: <20071005144510.GA7061@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58028
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751143AbXJKENh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:13:37 -0400
In-Reply-To: <20071005144510.GA7061@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Fri, 5 Oct 2007 18:45:10 +0400

> The code in netfilter/nfnetlink.c and in ./net/netlink/genetlink.c looks
> like outdated copy/paste from rtnetlink.c. Push them into sync with the
> original.
> 
> Changes from v1:
> - deleted comment in nfnetlink_rcv_msg by request of Patrick McHardy
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Patrick McHardy <kaber@trash.net>

Applied.
