From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: au1000_eth: get rid of unnecessary header.
Date: Tue, 14 Feb 2017 14:53:06 -0500 (EST)
Message-ID: <20170214.145306.2134798979815682111.davem@davemloft.net>
References: <20170214121107.249094-1-manuel.lauss@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: manuel.lauss@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41808 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751616AbdBNTxI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2017 14:53:08 -0500
In-Reply-To: <20170214121107.249094-1-manuel.lauss@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@gmail.com>
Date: Tue, 14 Feb 2017 13:11:07 +0100

> au1000_eth.h isn't used anywhere else, merge its contents into
> main driver file.
> 
> Signed-off-by: Manuel Lauss <manuel.lauss@gmail.com>

It is completely natural and normal to split the datastructure and
defines into a header file, used by only one file, the driver.

I'm not applying this, it doesn't really improve anything.

Thanks.
