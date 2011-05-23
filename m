From: David Miller <davem@davemloft.net>
Subject: [PATCH v7 0/4] rtcache removal
Date: Mon, 23 May 2011 17:33:54 -0400 (EDT)
Message-ID: <20110523.173354.1967946583925449473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41606 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754535Ab1EWVd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 17:33:56 -0400
Received: from localhost (nat-pool-rdu.redhat.com [66.187.233.202])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p4NLXsNs027573
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 23 May 2011 14:33:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Besides dealing with ongoing conflicts, new this time is patch #4,
which deletes rt->rt_src completely.

Enjoy.
