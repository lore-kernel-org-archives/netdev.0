From: frank.blaschka@de.ibm.com
Subject: [patch 0/4] s390: qeth fixes 2.6.28-rc1
Date: Fri, 24 Oct 2008 11:16:51 +0200
Message-ID: <20081024091651.603673000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:33647 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096AbYJXJRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:17:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

here are a couple of qeth bug fixes for 2.6.28-rc1

shortlog:
Ursula Braun (2)
qeth: remove non-recover-thread checkings
qeth: avoid skb_under_panic for malformatted inbound data

Frank Blaschka (2)
qeth: fix offset error in non prealloc header path
qeth: remove unnecessary support ckeck in sysfs route6

Thanks,
        Frank

-- 
