From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH 0/3 net-2.6.26] Compilation fixes.
Date: Mon, 31 Mar 2008 19:46:01 +0400
Message-ID: <1206978361.10660.31.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: yoshfuji <yoshfuji@linux-ipv6.org>,
	Netdev List <netdev@vger.kernel.org>,
	containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:21595 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754594AbYCaPqQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Mar 2008 11:46:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

Recently I have seen several issues post to the netdev@ blaming
inclusion of the net_namespace.h from seq_file. This set fixes this
problem after two small cleanups.

Regards,
	Den

