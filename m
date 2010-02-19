From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 19 Feb 2010 13:52:38 -0800
Message-ID: <201002192152.o1JLqcB6031953@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:43375 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752017Ab0BSVwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Feb 2010 16:52:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

The changes are as follows:

1) Explicitly included linux/vmalloc.h to address vmalloc errors.

2) Removed unused prototype.

3) Removed trailing blank lines.

We wish this patch to be considered for inclusion in net-next-2.6.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


