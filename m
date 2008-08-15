From: frank.blaschka@de.ibm.com
Subject: [patch 0/3] s390: qeth fixes for 2.6.27
Date: Fri, 15 Aug 2008 08:02:57 +0200
Message-ID: <20080815060257.501264000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:61379 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751205AbYHOGFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Aug 2008 02:05:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

here are some qeth fixes for 2.6.27

shortlog:
Ursula Braun (1)
qeth: use -EOPNOTSUPP instead of -ENOTSUPP.

Frank Blaschka (2)
qeth: l2 write unicast list to hardware
qeth: preallocated header account offset

Thanks,
        Frank
-- 
