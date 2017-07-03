From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: cdc_mbim: apply "NDP to end" quirk to HP lt4132
Date: Mon, 03 Jul 2017 02:20:06 -0700 (PDT)
Message-ID: <20170703.022006.735448811201221930.davem@davemloft.net>
References: <20170701132002.2891-1-tore@fud.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.org, linux-usb@vger.kernel.org,
        netdev@vger.kernel.org
To: tore@fud.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54648 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752987AbdGCJUJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 05:20:09 -0400
In-Reply-To: <20170701132002.2891-1-tore@fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tore Anderson <tore@fud.no>
Date: Sat,  1 Jul 2017 15:20:02 +0200

> The HP lt4132 LTE/HSPA+ 4G Module (03f0:a31d) is a rebranded Huawei
> ME906s-158 device. It, like the ME906s-158, requires the "NDP to end"
> quirk for correct operation.
> 
> Signed-off-by: Tore Anderson <tore@fud.no>

Applied, thank you.
