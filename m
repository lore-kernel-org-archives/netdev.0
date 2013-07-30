From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] fib_rules: add .suppress operation
Date: Tue, 30 Jul 2013 00:34:53 -0700 (PDT)
Message-ID: <20130730.003453.1523026053420683507.davem@davemloft.net>
References: <20130730065317.GH13357@zirkel.wertarbyte.de>
	<20130730.000306.1057653828787681847.davem@davemloft.net>
	<20130730072305.GB10550@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: stefan.tomanek@wertarbyte.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58465 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757816Ab3G3Hey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 03:34:54 -0400
In-Reply-To: <20130730072305.GB10550@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Date: Tue, 30 Jul 2013 09:23:05 +0200

> Well, to be fair, most comments in the existing code base actually use the style
> I employed (in fact, I was copying it), so it seems like a blurry line at least.

Existing mistakes are not excuses for duplicating them :-)

They are a good excuse to send a patch fixing them, however.
