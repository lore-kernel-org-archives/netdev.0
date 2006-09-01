From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/7] bonding: Miscellaneous small fixes
Date: Fri, 01 Sep 2006 15:07:52 -0700
Message-ID: <200609012207.k81M7qZt005145@death.nxdomain.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:23780 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751017AbWIAWHz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Sep 2006 18:07:55 -0400
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k81M7svm020328
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 18:07:54 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k81M7sx6262914
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 16:07:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k81M7sL4012539
	for <netdev@vger.kernel.org>; Fri, 1 Sep 2006 16:07:54 -0600
To: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Patch 1: Add 10 Gig support
	Patch 2: Convert delay value from s16 to int
	Patch 3: Format fix in seq_printf call
	Patch 4: Remove unneeded NULL test
	Patch 5: Handle large hard_header_len
	Patch 6: Add priv_flag to avoid event mishandling
	Patch 7: Don't release slaves when master is admin down

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

-- 
VGER BF report: U 0.499999
