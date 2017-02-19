From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Use common counter for capabilities checks
Date: Sun, 19 Feb 2017 18:12:15 -0500 (EST)
Message-ID: <20170219.181215.138855588227406588.davem@davemloft.net>
References: <1487182680-29421-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1487182680-29421-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54586 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdBSXM7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 18:12:59 -0500
In-Reply-To: <1487182680-29421-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 12:17:59 -0600

> Two different counters were being used for capabilities
> requests and queries. These commands are not called
> at the same time so there is no reason a single counter
> cannot be used.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
