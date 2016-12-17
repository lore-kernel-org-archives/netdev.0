From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmveth: calculate gso_segs for large packets
Date: Sat, 17 Dec 2016 10:23:43 -0500 (EST)
Message-ID: <20161217.102343.2038916849924187012.davem@davemloft.net>
References: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        marcelo.leitner@gmail.com, pradeeps@linux.vnet.ibm.com,
        jmaxwell37@gmail.com, zdai@us.ibm.com, eric.dumazet@gmail.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40400 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754060AbcLQPXo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 10:23:44 -0500
In-Reply-To: <1481674509-14256-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Tue, 13 Dec 2016 18:15:09 -0600

> Include calculations to compute the number of segments
> that comprise an aggregated large packet.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
