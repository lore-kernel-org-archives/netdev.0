From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/3] [AF_IUCV/IUCV] fixes for net-2.6.23
Date: Fri, 13 Jul 2007 10:50:53 +0200
Message-ID: <20070713085053.530802000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:25577 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752782AbXGMIws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Jul 2007 04:52:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Dave,

following three small patches contain:
- a configuration improvement for AF_IUCV socket support
- two fixes for iucv, the base code for IUCV related actions in z/VM

Thank you.
Ursula
