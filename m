From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 0/9] selective (per/namespace) flush of rt_cache
Date: Fri, 04 Jul 2008 17:16:00 +0400
Message-ID: <1215177360.27873.50.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Netdev List <netdev@vger.kernel.org>,
	containers <containers@lists.osdl.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:32214 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754168AbYGDNPl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2008 09:15:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Dave!

This series of patches implements selective rt cache flushing to make
sure that in one namespace we'll not been able to affect the performance
of other from the user space.

Regards,
	Den

