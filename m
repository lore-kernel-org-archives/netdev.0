From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/4] xfrm_user info leaks
Date: Mon, 28 Aug 2017 15:52:32 -0700 (PDT)
Message-ID: <20170828.155232.1540318133719787999.davem@davemloft.net>
References: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, herbert@gondor.apana.org.au,
        netdev@vger.kernel.org
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50410 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751231AbdH1Wwd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:52:33 -0400
In-Reply-To: <1503760140-9095-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Sat, 26 Aug 2017 17:08:56 +0200

> Hi David, Steffen,
> 
> the following series fixes a few info leaks due to missing padding byte
> initialization in the xfrm_user netlink interface.
> 
> Please apply!

Steffen please pick this up if you haven't already.

Thank you.
