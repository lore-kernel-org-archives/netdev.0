From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: [PATCH net 0/3] mlx4: Bug fixes in VFs resource management.
Date: Wed, 15 Feb 2012 18:22:34 +0200
Message-ID: <4F3BDBCA.2060008@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <yevgenyp@mellanox.co.il>,
	<eugenia@mellanox.co.il>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog118.obsmtp.com ([207.126.144.145]:57807 "HELO
	eu1sys200aog118.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751648Ab2BOQZk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 11:25:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave.

This is a subset of the patches that were submitted yesterday, and were accepted to net-next.
These 3 are bug fixes and need to be included in net.

 mlx4: fix buffer overrun
 mlx4: fix QP tree trashing
 mlx4: add unicast steering entries to resource tracker

 resource_tracker.c |   21 +++++++++++++--------
 1 file changed, 13 insertions(+), 8 deletions(-)


Thanks,
Yevgeny
