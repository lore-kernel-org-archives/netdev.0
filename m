From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/1] [8021q] qeth-related patch for net-2.6.24
Date: Mon, 08 Oct 2007 17:05:04 +0200
Message-ID: <20071008150504.855164000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:60799 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972AbXJHPIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 11:08:22 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Dave,

the following patch is intended for 2.6.24.
It adds the capability to create unique ipv6-addresses for vlan devices
based on shared network cards (for example: s390/net/qeth devices).

Regards, Ursula
