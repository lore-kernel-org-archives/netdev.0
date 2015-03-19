From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] tipc: small bugfix an support for
 datagram connect()
Date: Thu, 19 Mar 2015 12:26:24 -0400 (EDT)
Message-ID: <20150319.122624.458773914029779104.davem@davemloft.net>
References: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richard.alpe@ericsson.com, jon.maloy@ericsson.com,
	ying.xue@windriver.com, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861AbbCSQ01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2015 12:26:27 -0400
In-Reply-To: <1426752139-31519-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 19 Mar 2015 09:02:16 +0100

> Most notable in this series is patch#3 that allows programs to associate
> a tipc address with a connectionless (RDM/DGRAM) socket.
> 
> v2: Fix indent issue in patch#3

Series applied, thanks Erik.
