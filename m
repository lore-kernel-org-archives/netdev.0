From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Track state of adapter napis
Date: Fri, 05 May 2017 12:43:51 -0400 (EDT)
Message-ID: <20170505.124351.858047679431714903.davem@davemloft.net>
References: <47c6bbb6-faa0-b07b-871f-10e804b2152d@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com, brking@linux.vnet.ibm.com,
        muvic@linux.vnet.ibm.com
To: jallen@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750767AbdEEQnz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 5 May 2017 12:43:55 -0400
In-Reply-To: <47c6bbb6-faa0-b07b-871f-10e804b2152d@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Allen <jallen@linux.vnet.ibm.com>
Date: Fri, 5 May 2017 11:31:58 -0500

> Track the state of ibmvnic napis. The driver can get into states where it
> can be reset when napis are already disabled and attempting to disable them
> again will cause the driver to hang.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>

The net-next tree is closed, resubmit this when the net-next tree opens
back up.

Thanks.
