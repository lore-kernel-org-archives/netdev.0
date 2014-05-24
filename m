From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/1] tipc: Don't reset the timeout when
 restarting
Date: Sat, 24 May 2014 14:14:42 -0400 (EDT)
Message-ID: <20140524.141442.2162436160020181209.davem@davemloft.net>
References: <1400874912-25653-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net, acme@kernel.org,
	acme@redhat.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaEXSOo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 May 2014 14:14:44 -0400
In-Reply-To: <1400874912-25653-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Fri, 23 May 2014 15:55:12 -0400

> From: Arnaldo Carvalho de Melo <acme@kernel.org>
> 
> As it may then take longer than what the user specified using
> setsockopt(SO_RCVTIMEO).
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks.
