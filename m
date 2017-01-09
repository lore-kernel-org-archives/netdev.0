From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ibm: ibmvnic: use new api
 ethtool_{get|set}_link_ksettings
Date: Mon, 09 Jan 2017 12:10:51 -0500 (EST)
Message-ID: <20170109.121051.996723005103082118.davem@davemloft.net>
References: <1483825049-7501-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tlfalcon@linux.vnet.ibm.com, jallen@linux.vnet.ibm.com,
        benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42828 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763170AbdAIRKx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:10:53 -0500
In-Reply-To: <1483825049-7501-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Sat,  7 Jan 2017 22:37:29 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
