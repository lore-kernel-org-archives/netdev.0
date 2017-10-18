From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Fix calculation of number of TX header
 descriptors
Date: Wed, 18 Oct 2017 12:21:32 +0100 (WEST)
Message-ID: <20171018.122132.395131348429468554.davem@davemloft.net>
References: <1508166131-5141-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59800 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752921AbdJRLVh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 07:21:37 -0400
In-Reply-To: <1508166131-5141-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Mon, 16 Oct 2017 10:02:11 -0500

> This patch correctly sets the number of additional header descriptors
> that will be sent in an indirect SCRQ entry.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
