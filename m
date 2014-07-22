From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Fix recvmmsg timeout handling
Date: Mon, 21 Jul 2014 20:45:38 -0700 (PDT)
Message-ID: <20140721.204538.1952841990990568877.davem@davemloft.net>
References: <20140721192131.GA3212@kernel.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: caitlin.bestler@gmail.com, chris.friesen@windriver.com,
	David.Laight@ACULAB.COM, eliedebrauwer@gmail.com,
	mtk.manpages@gmail.com, nhorman@tuxdriver.com, neleai@seznam.cz,
	paul@paul-moore.com, remi@remlab.net, steve@chygwyn.com,
	netdev@vger.kernel.org
To: acme@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753205AbaGVDpo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2014 23:45:44 -0400
In-Reply-To: <20140721192131.GA3212@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnaldo Carvalho de Melo <acme@kernel.org>
Date: Mon, 21 Jul 2014 16:21:31 -0300

> 	Trying to get this merged, finally. I has whas has been
> discussed so far and agreed wrt the timeout handling.

This gets lots of rejects against the current 'net' tree.

Please respin and integrate Remi's Acked-by, thanks.
