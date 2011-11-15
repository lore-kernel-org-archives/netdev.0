From: frank.blaschka@de.ibm.com
Subject: [patch 0/5] s390: network driver bug fixes for 3.2.0 next rc
Date: Tue, 15 Nov 2011 13:31:11 +0100
Message-ID: <20111115123111.128739986@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([194.196.100.161]:39053 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752073Ab1KOMby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2011 07:31:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here are a couple of s390 network driver bug fixes for 3.2.0 next rc

shortlog:

Ursula Braun (2)
qeth: return with -EPERM if sniffing is not enabled
netiucv: reinsert dev_alloc_name for device naming

Frank Blaschka (1)
qeth: l3 fix rcu splat in xmit

Christian Borntraeger (1)
qeth: remove WARN_ON leftover

Einar Lueck (1)
qeth: Reduce CPU consumption through less SIGA-r calls

Thanks,
        Frank
