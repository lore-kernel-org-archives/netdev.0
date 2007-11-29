From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/1] s390: ctc patch for 2.6.24
Date: Thu, 29 Nov 2007 17:36:26 +0100
Message-ID: <20071129163626.573067000@linux.vnet.ibm.com>
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:19389 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760264AbXK2Qji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 11:39:38 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
The following patch is intended for 2.6.24 and repairs the
ctc driver by introducing alloc_netdev().
