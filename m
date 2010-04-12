From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 0/4] IPv6 addrconf related fixes
Date: Mon, 12 Apr 2010 08:41:30 -0700
Message-ID: <20100412154130.397252857@vyatta.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:47322 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752469Ab0DLPq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 11:46:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These apply to net-next, the problems do not exist in earlier kernels.
The problems started when I added changes to retain IPv6 addresses
when link goes down.

-- 

