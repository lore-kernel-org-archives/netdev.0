From: frank.blaschka@de.ibm.com
Subject: [patch 0/7] s390: network patches for net-next
Date: Tue, 01 Feb 2011 09:16:47 +0100
Message-ID: <20110201081647.173934635@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:56585 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495Ab1BAIR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Feb 2011 03:17:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some patches for net-next.

shortlog:
Ursula Braun (3)
qeth: show new mac-address if its setting fails
qeth: allow HiperSockets framesize change in suspend
qeth: allow OSA CHPARM change in suspend state

Frank Blaschka (1)
qeth: add more strict MTU checking

Horst Hartmann (1)
net,s390: provide architecture specific NET_SKB_PAD

Stefan Weil (2)
s390: Fix wrong size in memcmp (netiucv)
s390: Fix possibly wrong size in strncmp (smsgiucv)

Thanks,
        Frank

