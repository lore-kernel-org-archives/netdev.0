From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] dpaa_eth: a couple of fixes
Date: Sat, 17 Dec 2016 11:22:46 -0500 (EST)
Message-ID: <20161217.112246.248943325874592041.davem@davemloft.net>
References: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752821AbcLQQWv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Dec 2016 11:22:51 -0500
In-Reply-To: <1481807586-4798-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Thu, 15 Dec 2016 15:13:03 +0200

> This patch set introduces big endian accessors in the dpaa_eth driver
> making sure accesses to the QBMan HW are correct on little endian
> platforms. Removing a redundant Kconfig dependency on FSL_SOC.
> Adding myself as maintainer of the dpaa_eth driver.

Series applied, thanks.
