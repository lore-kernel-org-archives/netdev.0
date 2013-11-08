From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: icn: NULL dereference printing error message
Date: Thu, 07 Nov 2013 19:14:02 -0500 (EST)
Message-ID: <20131107.191402.296321377536769892.davem@davemloft.net>
References: <20131107075806.GO21844@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de,
	isdn4linux@listserv.isdn4linux.de, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56619 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753904Ab3KHAOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Nov 2013 19:14:04 -0500
In-Reply-To: <20131107075806.GO21844@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Thu, 7 Nov 2013 10:58:06 +0300

> "card2" is NULL here so I have changed it to use "id2" instead of
> "card2->interface.id".
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
