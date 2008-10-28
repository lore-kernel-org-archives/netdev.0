From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: [patch 0/2] veth:  veth pair device code cleanup
Date: Tue, 28 Oct 2008 22:11:42 +0100
Message-ID: <20081028211142.359911603@fr.ibm.com>
Cc: netdev@vger.kernel.org, xemul@openvz.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:65000 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753268AbYJ1VWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2008 17:22:22 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate6.de.ibm.com (8.13.8/8.13.8) with ESMTP id m9SLLWZo538836
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 21:21:32 GMT
Received: from d12av03.megacenter.de.ibm.com (d12av03.megacenter.de.ibm.com [9.149.165.213])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9SLLWpc2519214
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 22:21:32 +0100
Received: from d12av03.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av03.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9SLLO7h023213
	for <netdev@vger.kernel.org>; Tue, 28 Oct 2008 22:21:32 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The next two patches remove some unused code in the veth pair network device.

-- 
