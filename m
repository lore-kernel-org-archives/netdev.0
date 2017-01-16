From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 0/3] tipc: improve interaction socket-link
Date: Mon, 16 Jan 2017 14:45:14 -0500 (EST)
Message-ID: <20170116.144514.1071967219363714348.davem@davemloft.net>
References: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47464 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750788AbdAPTpQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Jan 2017 14:45:16 -0500
In-Reply-To: <1483457208-29033-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue,  3 Jan 2017 10:26:45 -0500

> We fix a very real starvation problem that may occur when a link
> encounters send buffer congestion. At the same time we make the 
> interaction between the socket and link layer simpler and more 
> consistent.

This doesn't apply to net-next, also the Date in your emails is 10 days
in the past.  What's going on here?
