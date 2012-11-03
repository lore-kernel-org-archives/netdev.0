From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] cpsw: fix resource leak for v3.8
Date: Sat, 03 Nov 2012 15:38:52 -0400 (EDT)
Message-ID: <20121103.153852.2120943445145443586.davem@davemloft.net>
References: <cover.1351930782.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	cyril@ti.com, mugunthanvnm@ti.com, hvaibhav@ti.com
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58247 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757055Ab2KCTiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Nov 2012 15:38:54 -0400
In-Reply-To: <cover.1351930782.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Richard Cochran <richardcochran@gmail.com>
Date: Sat,  3 Nov 2012 09:25:28 +0100

> While looking at the idea of removing all of the register offsets in
> the CPSW's device tree, I noticed that the driver would be leaking IO
> mappings. Although this is, strictly speaking, a bug fix, still it can
> wait to appear in v3.8, since there is no way to use the driver in
> v3.7 (or earlier) anyhow.

All applied, thanks.
