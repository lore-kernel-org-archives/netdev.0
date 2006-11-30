From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 0/5] NetXen: 1G/10G Ethernet Driver updates
Date: Thu, 30 Nov 2006 10:46:19 -0800
Message-ID: <20061130184619.GA32261@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amitkale@netxen.com, jeff@garzik.org, netxenproj@linsyssoft.com,
	rob@netxen.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:229 "EHLO e35.co.us.ibm.com")
	by vger.kernel.org with ESMTP id S1031176AbWK3Sqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Nov 2006 13:46:33 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id kAUIkOQP017597
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 13:46:24 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAUIkNqk476086
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 11:46:24 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAUIkNR6026710
	for <netdev@vger.kernel.org>; Thu, 30 Nov 2006 11:46:23 -0700
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The first patch sent by Amit on 29 Nov applied, but the following three
patches did not apply to Jeff's #upstream tree.  Here are the corrected
2nd, 3rd, and 4th patches, with a repeat of the 1st for completeness.
There is a 5th patch which fixes a bug caused by casting a 16-bit
variable into a 32-bit one and using the address.

-- 
Don Fry
brazilnut@us.ibm.com
