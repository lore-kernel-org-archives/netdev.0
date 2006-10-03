From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 0/5] ibmveth: various fixes
Date: Tue, 03 Oct 2006 12:24:17 -0500
Message-ID: <20061003172417.14851.63625.sendpatchset@ltcml8p1.rchland.ibm.com>
Cc: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49385 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S964903AbWJCS1H
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 14:27:07 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k93IR6b6002902
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 14:27:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k93IR6ak276040
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k93IR5QA024910
	for <netdev@vger.kernel.org>; Tue, 3 Oct 2006 12:27:06 -0600
To: netdev <netdev@vger.kernel.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,

Can you apply the following patches (hopefully for 2.6.19)?  They are the hardening of the initialization for kexec, adding netpoll, and some small fixes for bugs that people have been running into.

Thanks,
-- 
Santiago A. Leon
Power Linux Development
IBM Linux Technology Center
