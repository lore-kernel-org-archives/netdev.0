From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/s390/net/qeth_l2_main.c: use %pM to shown MAC
 address
Date: Wed, 30 Dec 2009 09:16:43 -0800 (PST)
Message-ID: <20091230.091643.246513654.davem@davemloft.net>
References: <BD79186B4FD85F4B8E60E381CAEE19090200F4CF@mi8nycmail19.Mi8.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org, blaschka@linux.vnet.ibm.com
To: hartleys@visionengravers.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51421
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752929AbZL3RQl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 12:16:41 -0500
In-Reply-To: <BD79186B4FD85F4B8E60E381CAEE19090200F4CF@mi8nycmail19.Mi8.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H Hartley Sweeten" <hartleys@visionengravers.com>
Date: Mon, 28 Dec 2009 18:39:26 -0500

> Use the %pM kernel extension to display the MAC address.
> 
> Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Applied.
