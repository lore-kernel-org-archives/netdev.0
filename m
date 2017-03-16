From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: bgmac: Allow MAC address to be
 specified in DTB
Date: Thu, 16 Mar 2017 11:58:05 -0700 (PDT)
Message-ID: <20170316.115805.378308171418529910.davem@davemloft.net>
References: <1489679338-39705-1-git-send-email-steven.lin1@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rafal@milecki.pl, jon.mason@broadcom.com, f.fainelli@gmail.com,
        tklauser@distanz.ch, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, bcm-kernel-feedback-list@broadcom.com
To: steven.lin1@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40754 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752119AbdCPS6J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 14:58:09 -0400
In-Reply-To: <1489679338-39705-1-git-send-email-steven.lin1@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Lin <steven.lin1@broadcom.com>
Date: Thu, 16 Mar 2017 11:48:58 -0400

> Allows the BCMA version of the bgmac driver to obtain MAC address
> from the device tree.  If no MAC address is specified there, then
> the previous behavior (obtaining MAC address from SPROM) is
> used.
> 
> Signed-off-by: Steve Lin <steven.lin1@broadcom.com>

Applied to net-next, thanks.
