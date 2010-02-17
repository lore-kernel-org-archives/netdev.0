From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 0/3] qlge: minor fixes.
Date: Wed, 17 Feb 2010 08:41:20 -0800
Message-ID: <1266424883-25927-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:36599 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751589Ab0BQQsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 11:48:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 Miscellaneous fixes for qlge:

1) Fix large ping (non-TCP/UDP) frame dropping when data spans
multiple  rx  buffers.
2) Fix mac address filter issue for bonding.
3) Fix ethtool loopback test.


