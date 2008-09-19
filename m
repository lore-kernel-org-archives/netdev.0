From: frank.blaschka@de.ibm.com
Subject: [patch 0/2] s390: qeth fixes 2.6.27-rc6
Date: Fri, 19 Sep 2008 12:56:01 +0200
Message-ID: <20080919105601.986966000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:32921 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbYISK6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 06:58:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jeff,

our internal regression found 2 more qeth bugs.

shortlog:
Ursula Braun (2)
qeth: use firmware MAC-address for layer2 hsi-devices
qeth: avoid qeth recovery problems

Thanks,
        Frank
-- 
