From: Patrick McHardy <kaber@trash.net>
Subject: Re: [2.6 patch] ipt_iprange.h must #include <linux/types.h>
Date: Tue, 17 Jul 2007 17:05:52 +0200
Message-ID: <469CDAD0.4000804@trash.net>
References: <20070715121419.GK3565@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org, linux-kernel@vger.kernel.org,
	cilly <cilly@cilly.mine.nu>
To: Adrian Bunk <bunk@stusta.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:46588 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbXGQPGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 11:06:00 -0400
In-Reply-To: <20070715121419.GK3565@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adrian Bunk wrote:
> ipt_iprange.h must #include <linux/types.h> since it uses __be32.


Applied, thanks.
