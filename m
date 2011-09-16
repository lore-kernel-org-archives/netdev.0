From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/4] ibmveth fixes
Date: Fri, 16 Sep 2011 15:28:03 -0400 (EDT)
Message-ID: <20110916.152803.861340383634129942.davem@davemloft.net>
References: <20110908004102.355674129@samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: santil@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
	rcj@linux.vnet.ibm.com, netdev@vger.kernel.org
To: anton@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56082 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084Ab1IPT2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2011 15:28:09 -0400
In-Reply-To: <20110908004102.355674129@samba.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>
Date: Thu, 08 Sep 2011 10:41:02 +1000

> Here are a number of fixes found during ibmveth testing.

All applied.

I love those "ret1", "ret2", "ret3", "ret4" variables.

Each successive number in the names gives such incredible
insight into the meaning and usage of the individual
variables, making it painless for reviewers to understand
this code.
