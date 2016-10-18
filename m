From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3 net] ibmvnic: Fix GFP_KERNEL allocation in
 interrupt context
Date: Tue, 18 Oct 2016 14:17:36 -0400 (EDT)
Message-ID: <20161018.141736.2204771476306440600.davem@davemloft.net>
References: <1476736090-13588-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1476736090-13588-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44998 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934451AbcJRSRi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2016 14:17:38 -0400
In-Reply-To: <1476736090-13588-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 17 Oct 2016 15:28:09 -0500

> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
