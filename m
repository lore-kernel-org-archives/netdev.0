From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] fix possible NULL pointer Oops in
 fib(6)_rule_suppress
Date: Mon, 18 Nov 2013 15:51:31 -0500 (EST)
Message-ID: <20131118.155131.2222251647728501102.davem@davemloft.net>
References: <5288CB1B.7050806@cogentembedded.com>
	<20131117144501.GC23153@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel.golle@gmail.com,
	sergei.shtylyov@cogentembedded.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49876 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751646Ab3KRUvd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 15:51:33 -0500
In-Reply-To: <20131117144501.GC23153@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Sun, 17 Nov 2013 15:45:01 +0100

> Reported-by: Daniel Golle <daniel.golle@gmail.com>
> Tested-by: Daniel Golle <daniel.golle@gmail.com>
> Signed-off-by: Stefan Tomanek <stefan.tomanek@wertarbyte.de>

Please us an appropriate subsystem prefix in your Subject lines, otherwise
the commit message header is less useful for others scanning the commit
log.

"inet: " would work well in this case.
