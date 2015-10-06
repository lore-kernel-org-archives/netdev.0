From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 1/2] regmap: Allow installing custom
 reg_update_bits function
Date: Tue, 06 Oct 2015 06:22:08 -0700 (PDT)
Message-ID: <20151006.062208.1154490262564827766.davem@davemloft.net>
References: <20151005142531.GS12635@sirena.org.uk>
	<20151005.232148.28609721470208031.davem@davemloft.net>
	<20151006095715.GF12635@sirena.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jon@ringle.org, gregkh@linuxfoundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: broonie@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46739 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751073AbbJFNGa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 09:06:30 -0400
In-Reply-To: <20151006095715.GF12635@sirena.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Brown <broonie@kernel.org>
Date: Tue, 6 Oct 2015 10:57:15 +0100

> I obviously can't just merge in net-next.

People do this all the time, when needed.  My history never changes,
and the networking tree is one of the first trees pulled into
linux-next, so this is always safe.
