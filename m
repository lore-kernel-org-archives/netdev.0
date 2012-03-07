From: frank.blaschka@de.ibm.com
Subject: [patch 0/7] s390: network driver fixes for net-next
Date: Wed, 07 Mar 2012 13:06:22 +0100
Message-ID: <20120307120622.922387262@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:50611 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756889Ab2CGMHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Mar 2012 07:07:14 -0500
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 7 Mar 2012 12:07:11 -0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

here is a couple of s390 network driver fixes for net-next

shortlog:

Ursula Braun (4)
af_iucv: handle netdev events
af_iucv: add shutdown for HS transport
ctcm: make ctcmpc debugging compilable
qeth: meaningful return code for set_mac_address

Frank Blaschka (1)
qeth: synchronize discipline module loading

Belinda Thompson(1)
ctcm: use correct idal word list for ctcmpc

Klaus-Dieter Wacker (1)
lcs: Return zero from ccwgroup devs set_offline function

Thanks,
        Frank
