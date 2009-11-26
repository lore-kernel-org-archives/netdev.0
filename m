From: Debashis Dutt <ddutt@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Thu, 26 Nov 2009 01:28:32 -0800
Message-ID: <200911260928.nAQ9SWX9003949@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:18730 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760166AbZKZJ20 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2009 04:28:26 -0500
Received: from blc-10-10.brocade.com (blc-10-10.brocade.com [10.2.2.245])	by
 discus.brocade.com (Postfix) with ESMTP id D158D23836E	for
 <netdev@vger.kernel.org>; Thu, 26 Nov 2009 01:28:32 -0800 (PST)
Received: from blc-10-10.brocade.com (localhost.localdomain [127.0.0.1])	by
 blc-10-10.brocade.com (8.13.1/8.13.1) with ESMTP id nAQ9SWNL003964	for
 <netdev@vger.kernel.org>; Thu, 26 Nov 2009 01:28:32 -0800
Received: (from ddutt@localhost)	by blc-10-10.brocade.com
 (8.13.1/8.13.1/Submit) id nAQ9SWX9003949	for netdev@vger.kernel.org; Thu, 26
 Nov 2009 01:28:32 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Debashis Dutt <ddutt@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

We wish this patch to be considered for inclusion in net-next-2.6.

The changes are as follows:

1. Removed inconsistent comments

2. Removed a couple of unused functions 

3. Addressed most of the review comments received from Joe Perches, Stephen Hemminger, 
   David Miller & others. 

We are working on addressing rest of the comments.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
---
 0 files changed


