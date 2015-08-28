From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/xen-netfront: only napi_synchronize() if
 running
Date: Fri, 28 Aug 2015 13:29:38 -0700 (PDT)
Message-ID: <20150828.132938.129290252917392389.davem@davemloft.net>
References: <1440692926.2546.31.camel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: 3chas3@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752855AbbH1U3j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 16:29:39 -0400
In-Reply-To: <1440692926.2546.31.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Charles (Chas) Williams" <3chas3@gmail.com>
Date: Thu, 27 Aug 2015 12:28:46 -0400

> From: Chas Williams <3chas3@gmail.com>
> 
> If an interface isn't running napi_synchronize() will hang forever.
 ...
> Signed-off-by: Chas Williams <3chas3@gmail.com>

Applied, thanks Chas.
