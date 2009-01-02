From: frank.blaschka@de.ibm.com
Subject: [patch 0/6] s390: qeth fixes 2.6.29
Date: Fri, 02 Jan 2009 16:01:39 +0100
Message-ID: <20090102150139.830998000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:34190 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750911AbZABPC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jan 2009 10:02:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

here are some qeth fixes for 2.6.29

shortlog:
Klaus Wacker (2)
qeth: HiperSockets mcl string conversion (pre z9 mach)
qeth: No large send using EDDP for HiperSockets.

Ursula Braun (2)
qeth: exploit source MAC address for inbound layer3 packets
qeth: avoid crash in case of layer mismatch for VSWITCH

Frank Blaschka (1)
qeth: do not spin for SETIP ip assist command

Heiko Carstens (1)
qeth: get rid of extra argument after printk to dev_* conversion

Thanks,
        Frank

-- 
