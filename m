From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 12 Feb 2010 06:00:57 -0800
Message-ID: <201002121400.o1CE0v9w031867@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:48121 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756458Ab0BLOBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2010 09:01:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

The changes are as follows:

1) Cleaned up extra BUG_ON()

2) Using mutex wherever appropriate

3) Using PCI_DEVICE_TABLE

We wish this patch to be considered for inclusion in net-next-2.6.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


