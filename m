From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 19/27] drivers/net/usb: fix sparse warnings: make
 symbols static
Date: Fri, 26 Dec 2008 00:08:56 -0800 (PST)
Message-ID: <20081226.000856.244642118.davem@davemloft.net>
References: <20081222191259.11807.53190.stgit@vmbox.hanneseder.net>
	<20081222191745.11807.75548.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54379
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750747AbYLZIIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Dec 2008 03:08:54 -0500
In-Reply-To: <20081222191745.11807.75548.stgit@vmbox.hanneseder.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Mon, 22 Dec 2008 20:17:46 +0100

> Fix this sparse warnings:
 ...
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

There have been changes in this area in the net-next-2.6 tree
so this patch won't apply.

Please regenerate this after I am able to merge all of my
networking bits to Linus for the 2.6.29 merge window.

Thanks.
