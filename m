From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] tipc: corrections related to tasklet job
 mechanism
Date: Tue, 10 Dec 2013 22:36:30 -0500 (EST)
Message-ID: <20131210.223630.1196018318397268975.davem@davemloft.net>
References: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751451Ab3LKDgc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Dec 2013 22:36:32 -0500
In-Reply-To: <1386658487-5463-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Mon,  9 Dec 2013 22:54:45 -0800

> These commits correct two bugs related to tipc' service for launching
> functions for asynchronous execution in a separate tasklet.

Series applied, thanks.
