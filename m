From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/9] s390/net updates
Date: Tue, 06 Jun 2017 13:06:46 -0400 (EDT)
Message-ID: <20170606.130646.351744100726961329.davem@davemloft.net>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        raspl@linux.vnet.ibm.com, ubraun@linux.vnet.ibm.com
To: jwi@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34558 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751614AbdFFRGy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 13:06:54 -0400
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Date: Tue,  6 Jun 2017 14:33:41 +0200

> please apply the following qeth updates for net-next.
> 
> Aside from some janitorial changes, this adds early setup for virtualized
> HiperSockets devices - building upon the code that landed via -net earlier.

Series applied, thanks.
