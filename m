From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: irda: au1k_ir: remove unused timer
Date: Tue, 14 Feb 2017 14:51:27 -0500 (EST)
Message-ID: <20170214.145127.2106240931595552622.davem@davemloft.net>
References: <20170214120804.248871-1-manuel.lauss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org
To: manuel.lauss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41786 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751418AbdBNTv3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:51:29 -0500
In-Reply-To: <20170214120804.248871-1-manuel.lauss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@gmail.com>
Date: Tue, 14 Feb 2017 13:08:03 +0100

> remove the unused timer.  I suppose it was intended as a timeout
> detector, but never properly implemented.
> 
> Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>

Applied to net-next.
