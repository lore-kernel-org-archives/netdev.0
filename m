From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/8] tipc: bug fixes and improvements
Date: Wed, 14 May 2014 15:20:41 -0400 (EDT)
Message-ID: <20140514.152041.2010140945900814477.davem@davemloft.net>
References: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750915AbaENTUo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 15:20:44 -0400
In-Reply-To: <1400060355-26308-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Wed, 14 May 2014 05:39:07 -0400

> Intensive and extensive testing has revealed some rather infrequent
> problems related to flow control, buffer handling and link
> establishment. Commits ##1 to 4 deal with these problems.
> 
> The remaining four commits are just code improvments, aiming at
> making the code more comprehensible and maintainable. There are
> no functional enhancements in this series.
> 
> v2: Fixed a typo in commit log #2. Otherwise no changes from v1.

Series applied, thanks.
