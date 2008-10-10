From: Andrew Morton <akpm@linux-foundation.org>
Subject: drivers/net/enic/vnic_cq.c
Date: Thu, 9 Oct 2008 21:12:17 -0700
Message-ID: <20081009211217.5f4e5f77.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37043 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751011AbYJJEM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 00:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


i386 allmodconfig, all trees applied:

drivers/net/enic/vnic_cq.c: In function 'vnic_cq_init':
drivers/net/enic/vnic_cq.c:65: error: implicit declaration of function 'writeq'

I can't immediately find an i386 implementation of writeq.


