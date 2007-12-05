From: Joe Perches <joe@perches.com>
Subject: Re: TCP event tracking via netlink...
Date: Wed, 05 Dec 2007 08:53:07 -0800
Message-ID: <1196873587.10819.30.camel@localhost>
References: <20071205.053031.87154402.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:1518 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750954AbXLEQ41 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Dec 2007 11:56:27 -0500
In-Reply-To: <20071205.053031.87154402.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> it occurred to me that we might want to do something
> like a state change event generator.

This could be a basis for an interesting TCP
performance tester.


