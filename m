From: Damian Lukowski <damian@tvk.rwth-aachen.de>
Subject: [PATCH 0/2] RTO connection timeout calculation
Date: Tue, 01 Sep 2009 22:23:56 +0200
Message-ID: <4A9D82DC.50508@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7BIT
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:54483 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752033AbZIAUXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 16:23:54 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KPB0097C7BWNDB0@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Tue, 01 Sep 2009 22:23:56 +0200 (CEST)
Received: from [137.226.143.131] (nexus.tvk.RWTH-Aachen.DE [137.226.143.131])
	by relay.rwth-aachen.de (8.13.8+Sun/8.13.8/1) with ESMTP id n81KNuel004216	for
 <netdev@vger.kernel.org>; Tue, 01 Sep 2009 22:23:56 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this series of patches implements some changes concerning the RTO
retransmission timeouts.

1) retransmits_timed_out() is commented shortly and has
   more meaningful names.
2) The sysctl documentation is being updated.

Regards

Signed-off-by: Damian Lukowski <damian@tvk.rwth-aachen.de>

