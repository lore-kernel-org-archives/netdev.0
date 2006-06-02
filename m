From: Christoph Raisch <RAISCH@de.ibm.com>
Subject: new driver for IBM ethernet chip
Date: Fri, 2 Jun 2006 13:02:37 +0200
Message-ID: <OFA75C1070.77D8B8F0-ONC125717F.003D730C-C1257181.003C592B@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Marcus Eder <MEDER@de.ibm.com>,
	Jan-Bernd Themann <THEMANN@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:46824 "EHLO
	mtagate5.de.ibm.com") by vger.kernel.org with ESMTP
	id S1751389AbWFBLAt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jun 2006 07:00:49 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.6/8.13.6) with ESMTP id k52B0mNK097650
	for <netdev@vger.kernel.org>; Fri, 2 Jun 2006 11:00:48 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k52B2dIj031306
	for <netdev@vger.kernel.org>; Fri, 2 Jun 2006 13:02:39 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k52B0lfY019602
	for <netdev@vger.kernel.org>; Fri, 2 Jun 2006 13:00:47 +0200
Received: from d12ml067.megacenter.de.ibm.com (d12ml067.megacenter.de.ibm.com [9.149.164.162])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k52B0l3g019597
	for <netdev@vger.kernel.org>; Fri, 2 Jun 2006 13:00:47 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We're currently developing a new Ethernet device driver for a 10G IBM chip
for System p. (ppc64)

A later version of the driver should end up in mainline kernel.
How should we proceed to get first comments by the community?
Either post this code as a patch to netdev or
put a full tarball on for example sourceforge?


Gruss / Regards . . . Christoph Raisch

christoph raisch, HCAD teamlead, IODF2 (d/3627), ibm boeblingen lab,
phone: (+49/0)7031-16 4584,  fax: -16 2042, loc: 71032-05-003, internet:
raisch@de.ibm.com

