From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/1] [IUCV] patch for net-2.6.25
Date: Mon, 03 Mar 2008 14:16:10 +0100
Message-ID: <20080303131610.405835000@linux.vnet.ibm.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.de.ibm.com ([195.212.29.157]:64506 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752191AbYCCNT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2008 08:19:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Dave,

this patch is intended for 2.6.25.
It enables compilation of net/iucv/iucv.c with !CONFIG_SMP.
Thanks to Jeff Sipek and Heiko Carstens.

Regards,
Ursula Braun
