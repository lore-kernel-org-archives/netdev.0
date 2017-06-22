From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2 net-next] ibmvnic: Correct long-term-mapped buffer
 error handling
Date: Thu, 22 Jun 2017 11:31:56 -0400 (EDT)
Message-ID: <20170622.113156.2305691329792321950.davem@davemloft.net>
References: <1498074781-17565-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36246 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751927AbdFVPb6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2017 11:31:58 -0400
In-Reply-To: <1498074781-17565-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 21 Jun 2017 14:52:59 -0500

> This patch set fixes the error-handling of long-term-mapped buffers
> during adapter initialization and reset. The first patch fixes a bug
> in an incorrectly defined descriptor that was keeping the return
> codes from the VIO server from being properly checked. The second patch
> fixes and cleans up the error-handling implementation.

Series applied, thanks.
