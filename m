From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 net] ibmvnic: Allocate number of rx/tx buffers
 agreed on by firmware
Date: Tue, 07 Mar 2017 14:14:49 -0800 (PST)
Message-ID: <20170307.141449.1256726423787086410.davem@davemloft.net>
References: <1488737922-17305-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1488737922-17305-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        nfont@linux.vnet.ibm.com, wvoigt@us.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37856 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756221AbdCGWPr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 17:15:47 -0500
In-Reply-To: <1488737922-17305-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Sun,  5 Mar 2017 12:18:42 -0600

> The amount of TX/RX buffers that the vNIC driver currently allocates
> is different from the amount agreed upon in negotiation with firmware.
> Correct that by allocating the requested number of buffers confirmed
> by firmware.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
