From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bugfix: network namespace & device dummy
Date: Mon, 17 Dec 2012 11:13:36 -0800 (PST)
Message-ID: <20121217.111336.1116224157525741208.davem@davemloft.net>
References: <50CF1797.803@guap.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lve@guap.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51566 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752091Ab2LQTNg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 14:13:36 -0500
In-Reply-To: <50CF1797.803@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "V. Lavrov" <lve@guap.ru>
Date: Mon, 17 Dec 2012 17:01:11 +0400

> If container has a network device dummyX (with lxc.network.type =
> phys), then it disappears from the system after you close the
> container.
> The patch returns the device dummyX to the initial network namespace
> after container is closed.
> 
> Signed-off-by: Vitaly Lavrov <lve@guap.ru>

This patch is mangled by your email client.

Do not submit any new patches until you can successfully email
them to yourself, then successfully apply the patch that you
receive in that email.

Because that is exactly what you are asking us to do.
