From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] qeth bug fixes for 2.6.34 next rc
Date: Tue, 09 Mar 2010 07:36:52 +0100
Message-ID: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.17.165]:56555 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751781Ab0CIGji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some qeth bug fixes for 2.6.34 next rc

shortlog:

Ursula Braun (3)
qeth: enable kmsg hash processing in qeth_core_sys.c
qeth: set promisc off after trace disabling failure
qeth: no recovery after layer mismatch (z/VM NICs)

Frank Blaschka (2)
qeth: l3 send dhcp in non pass thru mode
qeth: change checksumming default for HiperSockets

Thanks,
        Frank
