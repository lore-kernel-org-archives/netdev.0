From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cls_u32: don't bother explicitly initializing
 ->divisor to zero
Date: Mon, 09 Jan 2017 14:27:42 -0500 (EST)
Message-ID: <20170109.142742.2143034709434341382.davem@davemloft.net>
References: <20170108164946.GA10605@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: 00moses.alexander00@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48202 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751038AbdAIT1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:27:43 -0500
In-Reply-To: <20170108164946.GA10605@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexandru Moise <00moses.alexander00@gmail.com>
Date: Sun, 8 Jan 2017 18:49:46 +0200

> This struct member is already initialized to zero upon root_ht's
> allocation via kzalloc().
> 
> Signed-off-by: Alexandru Moise <00moses.alexander00@gmail.com>

Applied, thanks.
