From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] cxgb4: Clear On FLASH config file after a FW
 upgrade
Date: Tue, 08 Aug 2017 20:36:01 -0700 (PDT)
Message-ID: <20170808.203601.560130648724024365.davem@davemloft.net>
References: <1502171452-32389-1-git-send-email-ganeshgr@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nirranjan@chelsio.com,
        indranil@chelsio.com, venkatesh@chelsio.com, leedom@chelsio.com,
        arjun@chelsio.com
To: ganeshgr@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60006 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752497AbdHIDgC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 23:36:02 -0400
In-Reply-To: <1502171452-32389-1-git-send-email-ganeshgr@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ganesh Goudar <ganeshgr@chelsio.com>
Date: Tue,  8 Aug 2017 11:20:52 +0530

> From: Arjun Vynipadath <arjun@chelsio.com>
> 
> Because Firmware and the Firmware Configuration File need to be
> in sync; clear out any On-FLASH Firmware Configuration File when new
> Firmware is loaded.  This will avoid difficult to diagnose and fix
> problems with a mis-matched Firmware Configuration File which prevents the
> adapter from being initialized.
> 
> Original work by: Casey Leedom <leedom@chelsio.com>
> Signed-off-by: Arjun Vynipadath <arjun@chelsio.com>
> Signed-off-by: Ganesh Goudar <ganeshgr@chelsio.com>

Applied, thanks.
