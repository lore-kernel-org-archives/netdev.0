From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macsec: add genl family module alias
Date: Tue, 22 Aug 2017 14:26:15 -0700 (PDT)
Message-ID: <20170822.142615.941454194983630857.davem@davemloft.net>
References: <dde846e6ac5c2bc4189c240be6ccaa54d3b60d5e.1503406499.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdHVV0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 17:26:16 -0400
In-Reply-To: <dde846e6ac5c2bc4189c240be6ccaa54d3b60d5e.1503406499.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 22 Aug 2017 15:36:08 +0200

> This helps tools such as wpa_supplicant can start even if the macsec
> module isn't loaded yet.
> 
> Fixes: c09440f7dcb3 ("macsec: introduce IEEE 802.1AE driver")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied and queued up for -stable, thanks.
