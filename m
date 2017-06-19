From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 1/2] tcp: md5: add an address prefix for key lookup
Date: Mon, 19 Jun 2017 13:51:50 -0400 (EDT)
Message-ID: <20170619.135150.1015653914955537182.davem@davemloft.net>
References: <20170610021449.16091-1-colona@arista.com>
        <20170616010707.27666-1-colona@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colona@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751317AbdFSRvw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Jun 2017 13:51:52 -0400
In-Reply-To: <20170616010707.27666-1-colona@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Delalande <colona@arista.com>
Date: Thu, 15 Jun 2017 18:07:06 -0700

> This allows the keys used for TCP MD5 signature to be used for whole
> range of addresses, specified with a prefix length, instead of only one
> address as it currently is.
> 
> Signed-off-by: Bob Gilligan <gilligan@arista.com>
> Signed-off-by: Eric Mowat <mowat@arista.com>
> Signed-off-by: Ivan Delalande <colona@arista.com>

Applied.
