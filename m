From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 0/5] mv643xx_eth updates for 2.6.31
Date: Wed, 6 May 2009 15:00:47 +0200
Message-ID: <20090506130047.GE24429@mail.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:40427 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbZEFMyD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 08:54:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In this series: some more minor cleanups, and adding support for yet
another variation of the mv643xx_eth hardware block, one which uses
the upper queue interrupt bits for other purposes.

The last patch in the series depends on the mv643xx_eth oom fix I
sent earlier, but as you pulled net-2.6 into net-next-2.6 just after
applying that patch this should apply against net-next-2.6 OK.

Thanks!
