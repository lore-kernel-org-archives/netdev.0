From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 0/2] packet: Report fanout and rings via diag
Date: Thu, 16 Aug 2012 19:31:38 +0400
Message-ID: <502D125A.40701@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:29154 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642Ab2HPPbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2012 11:31:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

After this the packet diag module reports everything that can be
configured on a packet socket via AF_PACKET-specific API.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
