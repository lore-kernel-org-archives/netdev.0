From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH net-next 0/6][NETNS]: Revisit read-only-in-namespaces sysctls.
Date: Mon, 19 May 2008 19:50:46 +0400
Message-ID: <4831A1D6.4090503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43627 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391AbYESPxP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 May 2008 11:53:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hope, it's not too early to post to net-next, but the one
looks alive for quite a long time already :)

After sysctl tables permissions are finally (thanks to Andrew)
in mainline I have revisited issue with sysctls, that are to
be read-only in net namespaces.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
