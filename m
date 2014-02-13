From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net: remove useless if check from
 register_netdevice()
Date: Thu, 13 Feb 2014 14:20:35 -0500 (EST)
Message-ID: <20140213.142035.497708478531901279.davem@davemloft.net>
References: <1392266829-2365-1-git-send-email-kda@linux-powerpc.org>
	<CAADnVQJwP+ThozpeKOEvzoJRkYQvZgWyM9U+ixyeKKH9nkNb6w@mail.gmail.com>
	<CAOJe8K2iTsv-HUEotjwpc7s9LMEU6+nMfK5VWWF0tcMLhYBS6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: kda@linux-powerpc.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48749 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbaBMTUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 14:20:38 -0500
In-Reply-To: <CAOJe8K2iTsv-HUEotjwpc7s9LMEU6+nMfK5VWWF0tcMLhYBS6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov <kda@linux-powerpc.org>
Date: Thu, 13 Feb 2014 21:15:46 +0400

> All of the users of ndo_init return negative error code on error path.
> Only staging stuff tries to use positive codes like octeon ethernet
> which does request_irq inside ndo_open...

Do not top-post, please.

Quote the necessary material of the person you are replying to, then
provide your response underneath.
