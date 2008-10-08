From: "Denis V. Lunev" <den@openvz.org>
Subject: [PATCH net-next 0/14] ipv6: making IP/ICMP mibs per/namespace
Date: Wed, 08 Oct 2008 15:51:25 +0400
Message-ID: <1223466685.7184.13.camel@iris.sw.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.linux-foundation.org,
	den@openvz.org, benjamin.thery@bull.net, dlezcano@fr.ibm.com,
	xemul@openvz.org, yoshfuji@linux-ipv6.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:39933 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750781AbYJHLvd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Oct 2008 07:51:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series makes IP6/ICMP6 mibs per/namespace using
infrastructure accepted with UDP6 mib infrastructure.

Regards,
	Den

