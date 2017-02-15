From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Fix endian errors in error reporting
 output
Date: Wed, 15 Feb 2017 14:49:14 -0500 (EST)
Message-ID: <20170215.144914.1443528426798877626.davem@davemloft.net>
References: <1487176413-16523-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751313AbdBOTtQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2017 14:49:16 -0500
In-Reply-To: <1487176413-16523-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 15 Feb 2017 10:33:33 -0600

> Error reports received from firmware were not being converted from
> big endian values, leading to bogus error codes reported on little
> endian systems.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
