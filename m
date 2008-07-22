From: frank.blaschka@de.ibm.com
Subject: [patch 0/1] [RESEND] s390: qeth build fix for 2.6.27
Date: Tue, 22 Jul 2008 09:39:24 +0200
Message-ID: <20080722073924.165257000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	bunk@kernel.org, kaber@trash.net
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.29.155]:63073 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430AbYGVHls (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jul 2008 03:41:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

a better patch from Patrick to fix the broken s390 qeth build
(Thanks to Patrik)

shortlog:
Patrick McHardy (1)
qeth: fix build error caused by VLAN changes

Thanks,
        Frank

-- 
