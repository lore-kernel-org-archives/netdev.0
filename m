From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: [PATCH 0/6] IPv6: IPv6 tunnel fixes
Date: Thu, 02 Nov 2006 13:27:05 +0200
Message-ID: <4549D609.8060202@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:42121 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1752856AbWKBL1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 06:27:39 -0500
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

the following incremental patches contain several fixes to ip6_tunnel.c.
They are in chronological order, so the most critical one is
unfortunately last. Many thanks to Tero Kauppinen for reporting that one!

The patches are sent as attachments as my mailer has at least previously
messed up inlined patches.

Regards,
Ville
