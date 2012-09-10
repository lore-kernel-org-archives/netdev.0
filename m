From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] etherdevice: introduce help function
 eth_zero_addr()
Date: Mon, 10 Sep 2012 15:50:05 -0400 (EDT)
Message-ID: <20120910.155005.1299267014702772651.davem@davemloft.net>
References: <504BFFBC.9070209@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: djduanjiong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33128 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754213Ab2IJTuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 15:50:06 -0400
In-Reply-To: <504BFFBC.9070209@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <djduanjiong@gmail.com>
Date: Sun, 09 Sep 2012 10:32:28 +0800

> a lot of code has either the memset or an inefficient copy
> from a static array that contains the all-zeros Ethernet address.
> Introduce help function eth_zero_addr() to fill an address with
> all zeros, making the code clearer and allowing us to get rid of
> some constant arrays.
> 
> Signed-off-by: Duan Jiong <djduanjiong@gmail.com>

Applied, thanks.
