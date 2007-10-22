From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/2] remove header_ops bug in qeth driver (part 2)
Date: Mon, 22 Oct 2007 16:16:13 +0200
Message-ID: <20071022141613.957690000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com, mschwid2@linux.vnet.ibm.com,
	heicars2@linux.vnet.ibm.com, apw@shadowen.org,
	kamalesh@linux.vnet.ibm.com, kaber@trash.net,
	shemminger@linux-foundation.org
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:10101 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925AbXJVOUs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 10:20:48 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Jeff,

another patch in include/linux/netdevice.h is necessary
to solve the qeth bug of 2.6.23-git

And an update of the MAINTAINERS file is appended.

Regards,   Ursula Braun
