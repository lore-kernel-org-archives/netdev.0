From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/3] iucv / af_iucv patches for net-2.6.26
Date: Tue, 01 Apr 2008 15:45:21 +0200
Message-ID: <20080401134521.169525000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:23513 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754948AbYDAN5J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 09:57:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Dave,

the following 3 patches are intended for 2.6.26.
They are built against git/davem/net-2.6.26.
They contain:
af_iucv: usage of newer non-deprecated __RW_LOCK_UNLOCKED macro
iucv:    get rid of in_atomic() use
iucv:    delay bus registration until core is ready

Regards, Ursula
