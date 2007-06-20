From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 0/8] s390: network device driver fixes
Date: Wed, 20 Jun 2007 12:48:17 +0200
Message-ID: <20070620104817.GA2627@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fpavlic@de.ibm.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:56439 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752347AbXFTKsy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 06:48:54 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5KAmp55004711
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 06:48:51 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5KAmp2J131718
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 04:48:51 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5KAmoeN016518
	for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 04:48:51 -0600
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff,
following eight patches are all fixes for s390 network
device driver qeth, claw and netiucv.

I would be glad to see them going into 2.6.22 although
I know it is quite late .

Thank you.

Frank
