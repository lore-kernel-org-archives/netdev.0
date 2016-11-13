From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] ibmvnic: Fix size of debugfs name buffer
Date: Sun, 13 Nov 2016 13:42:50 -0500 (EST)
Message-ID: <20161113.134250.2183707738337451951.davem@davemloft.net>
References: <1478883646-10760-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
        <1478883646-10760-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mwb@linux.vnet.ibm.com
To: tlfalcon@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45436 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934249AbcKMSvv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 13:51:51 -0500
In-Reply-To: <1478883646-10760-2-git-send-email-tlfalcon@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Date: Fri, 11 Nov 2016 11:00:46 -0600

> This mistake was causing debugfs directory creation
> failures when multiple ibmvnic devices were probed.
> 
> Signed-off-by: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>

Applied.
