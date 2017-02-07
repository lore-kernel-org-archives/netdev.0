From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] liquidio: do not dereference pointer if it's
 NULL
Date: Tue, 07 Feb 2017 15:37:54 -0500 (EST)
Message-ID: <20170207.153754.1045449863986754945.davem@davemloft.net>
References: <20170207201058.GA8962@felix.cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        dan.carpenter@oracle.com
To: felix.manlunas@cavium.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56946 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932269AbdBGUiG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 15:38:06 -0500
In-Reply-To: <20170207201058.GA8962@felix.cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Felix Manlunas <felix.manlunas@cavium.com>
Date: Tue, 7 Feb 2017 12:10:58 -0800

> Fix smatch errors by not dereferencing iq pointer if it's NULL.
> 
> See http://marc.info/?l=kernel-janitors&m=148637299004834&w=2
> 
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>

Applied, thanks.
