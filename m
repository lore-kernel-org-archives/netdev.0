From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] ipv6: udp: Optimise multicast reception
Date: Fri, 06 Nov 2009 17:30:53 +0100
Message-ID: <4AF44F3D.3050407@gmail.com>
References: <200911052033.21964.lgrijincu@ixiacom.com> <20091106.004215.114490979.davem@davemloft.net> <200911061604.21465.lgrijincu@ixiacom.com> <4AF43C5E.4060300@gmail.com> <4AF447F7.6000700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Lucian Adrian Grijincu <lgrijincu@ixiacom.com>,
	netdev@vger.kernel.org, opurdila@ixiacom.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36727 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758611AbZKFQax (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2009 11:30:53 -0500
In-Reply-To: <4AF447F7.6000700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

And here is the ipv6 part as well

[PATCH net-next-2.6] ipv6: udp: Optimise multicast reception
