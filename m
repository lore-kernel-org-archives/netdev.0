From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/3] iucv / af_iucv patches for net-2.6.26
Date: Thu, 05 Jun 2008 11:08:37 +0200
Message-ID: <20080605090837.212105000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:44578 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbYFEJOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 05:14:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Dave,

the following 3 small patches are intended for 2.6.26.
They are built against git/davem/net-2.6.26
They contain:
iucv:    remove WARNING              (from Heiko Carstens)
iucv:    cpu hotplug fix             (from Heiko Carstens)
af_iucv: exploit message class field (from Ursula Braun)

Regards, Ursula

