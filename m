From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] make netlink processing routines semi-synchronious	(inspired
 by rtnl) v2
Date: Mon, 01 Oct 2007 16:27:31 +0200
Message-ID: <470103D3.4020004@trash.net>
References: <20071001142558.GA9997@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, johannes@sipsolutions.net, tgraf@suug.ch,
	pablo@netfilter.org, netdev@vger.kernel.org
To: "Denis V. Lunev" <den@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:34008 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752075AbXJAO16 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2007 10:27:58 -0400
In-Reply-To: <20071001142558.GA9997@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Denis V. Lunev wrote:
> The code in netfilter/nfnetlink.c and in ./net/netlink/genetlink.c looks
> like outdated copy/paste from rtnetlink.c. Push them into sync with the
> original.
> 
> Changes from v1:
> - deleted comment in nfnetlink_rcv_msg by request of Patrick McHardy

Thanks.

> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Acked-by: Patrick McHardy <kaber@trash.net>
