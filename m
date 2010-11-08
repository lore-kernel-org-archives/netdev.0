From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: qeth bug fixes for 2.6.37 next rc
Date: Mon, 08 Nov 2010 14:03:47 +0100
Message-ID: <20101108130347.973708765@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:35854 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752104Ab0KHNE3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 08:04:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some qeth bug fixes for 2.6.37 next rc (net-2.6)

shortlog:

Ursula Braun (1)
qeth: remove dev_queue_xmit invocation

Frank Blaschka (1)
qeth: fix race condition during device startup

Thanks,
        Frank

