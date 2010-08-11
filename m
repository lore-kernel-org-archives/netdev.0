From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 0/6] bna: Brocade 10Gb Ethernet device driver
Date: Tue, 10 Aug 2010 21:18:35 -0700
Message-ID: <201008110418.o7B4IZeL002650@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:60480 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750742Ab0HKESh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 00:18:37 -0400
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.3/8.14.3) with SMTP id o7B461qN020586
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 21:18:37 -0700
Received: from hq-exedge.brocade.com (hq-exedge.brocade.com [66.243.153.82])
	by mx0a-000f0801.pphosted.com with ESMTP id qkmbv80b8-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 10 Aug 2010 21:18:37 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 0/6 which contains the summary of changes we've
done in this particular submission for Brocade's BR1010/BR1020
10Gb CEE capable ethernet adapter. Source is based against
net-next-2.6.

The changes are as follows:

- Minimized the scope of some APIs as per the comments

- Converted spin_lock _irq()/spin_unlock_irq() to safer spin_lock_irqsave()/spin_lock_irqrestore() respectively

We wish these patches to be considered for inclusion in net-next-2.6.

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 0 files changed


