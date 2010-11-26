From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: qeth patches for net-next
Date: Fri, 26 Nov 2010 13:41:16 +0100
Message-ID: <20101126124116.123736494@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([194.196.100.162]:57042 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752941Ab0KZMmT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Nov 2010 07:42:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are some patches for net-next.
The set contains also the patch from Sachin Sant to fix the s390 build.

shortlog:
Ursula Braun (1)
qeth: enable interface setup if LAN is offline

Joe Perches (1)
drivers/s390/net: Remove unnecessary semicolons

Sachin Sant (1)
qeth lcs: convert mc rwlock to RCU

Frank Blaschka (1)
qeth: l3 fix len in tso hdr

Thanks,
        Frank
