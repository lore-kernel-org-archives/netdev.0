From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fsl/fman: add dependency on HAS_DMA
Date: Tue, 27 Jun 2017 15:42:42 -0400 (EDT)
Message-ID: <20170627.154242.1682587691752013432.davem@davemloft.net>
References: <1498492020-17623-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, geert@linux-m68k.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44712 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752814AbdF0Tmo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 15:42:44 -0400
In-Reply-To: <1498492020-17623-1-git-send-email-madalin.bucur@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Mon, 26 Jun 2017 18:47:00 +0300

> A previous commit (5567e989198b5a8d) inserted a dependency on DMA
> API that requires HAS_DMA to be added in Kconfig.
> 
> Signed-off-by: Madalin Bucur <madalin.bucur@nxp.com>

Applied, thank you.
