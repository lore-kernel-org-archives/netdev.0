From: David Miller <davem@davemloft.net>
Subject: Re: [B.A.T.M.A.N.] [PATCH 01/10] batman-adv: fix soft-interface
 MTU computation
Date: Tue, 18 Feb 2014 13:22:21 -0500 (EST)
Message-ID: <20140218.132221.1485466625541655137.davem@davemloft.net>
References: <1392670129-2498-2-git-send-email-antonio@meshcoding.com>
	<20140217.161314.741869447870850076.davem@davemloft.net>
	<53030165.2050404@meshcoding.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	mareklindner@neomailbox.ch
To: antonio@meshcoding.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbaBRSWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 13:22:25 -0500
In-Reply-To: <53030165.2050404@meshcoding.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@meshcoding.com>
Date: Tue, 18 Feb 2014 07:44:53 +0100

> Unfortunately this is not the only "fake-atomic" variable we have.

:-(

> We'll send a change for this later within our pull request for net-next, ok?

Fair enough.
