From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/1] tipc: eliminate obsolete socket locking policy
 description
Date: Sat, 19 Nov 2016 22:15:54 -0500 (EST)
Message-ID: <20161119.221554.1604467839323600048.davem@davemloft.net>
References: <1479584827-21772-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753032AbcKTDP4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:15:56 -0500
In-Reply-To: <1479584827-21772-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Sat, 19 Nov 2016 14:47:07 -0500

> The comment block in socket.c describing the locking policy is
> obsolete, and does not reflect current reality. We remove it in this
> commit.
> 
> Since the current locking policy is much simpler and follows a
> mainstream approach, we see no need to add a new description.
> 
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

Applied, thanks Jon.
