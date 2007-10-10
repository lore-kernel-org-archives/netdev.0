From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 0/9]: bonding support for IPoIB
Date: Tue,  9 Oct 2007 19:43:35 -0700
Message-ID: <1191984224957-git-send-email-fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:55234 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbXJJCns (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 22:43:48 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11.20060308/8.13.8) with ESMTP id l9A1Z9Zq009694
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 21:35:09 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9A2hkMS407588
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:46 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9A2hjHg001972
	for <netdev@vger.kernel.org>; Tue, 9 Oct 2007 20:43:45 -0600
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	9 patch series providing IPoIB support for bonding

	This should correct the compile errors from the last posting; it
builds ok for me against netdev-2.6 upstream pulled about an hour ago.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
