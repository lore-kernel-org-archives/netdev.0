From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6 addrconf: Fix interface identifiers of
 802.15.4 devices.
Date: Tue, 29 Jan 2013 15:45:53 -0500 (EST)
Message-ID: <20130129.154553.2015134791810319057.davem@davemloft.net>
References: <5106E32D.1080309@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net,
	alex.bluesman.smirnov@gmail.com
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753922Ab3A2Upz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 15:45:55 -0500
In-Reply-To: <5106E32D.1080309@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 29 Jan 2013 05:44:29 +0900

> The "Universal/Local" (U/L) bit must be complmented according to RFC4944
> and RFC2464.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
