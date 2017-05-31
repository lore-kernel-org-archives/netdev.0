From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ibmvnic: Update module author
Date: Wed, 31 May 2017 17:12:03 -0400 (EDT)
Message-ID: <20170531.171203.1567468797463479514.davem@davemloft.net>
References: <1496262931-15978-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nfont@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44576 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750954AbdEaVMF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 17:12:05 -0400
In-Reply-To: <1496262931-15978-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Wed, 31 May 2017 15:35:31 -0500

> Update the module author to be one of the original co-maintainers
> of the driver. The original author left the project long ago and
> so far has not responded to emails sent to the listed address.
> 
> Signed-off-by: John Allen <jallen@linux.vnet.ibm.com>
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

It's MODULE_AUTHOR not MODULE_MAINTAINER.
