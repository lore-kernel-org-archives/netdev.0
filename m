From: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Subject: Re: [PATCH v4] fib_rules: add .suppress operation
Date: Thu, 1 Aug 2013 03:26:21 +0200
Message-ID: <20130801012621.GM10550@zirkel.wertarbyte.de>
References: <20130727070758.GA23904@order.stressinduktion.org>
 <20130801001715.GA27283@zirkel.wertarbyte.de>
 <20130731.172740.549970338016485006.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	bsderandrew@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zirkel.wertarbyte.de ([188.40.44.137]:58353 "EHLO
	zirkel.wertarbyte.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab3HAB0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 21:26:22 -0400
Content-Disposition: inline
In-Reply-To: <20130731.172740.549970338016485006.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dies schrieb David Miller (davem@davemloft.net):

> Applied, thanks.

Thank you very much; Hannes Frederic Sowa noted some irregularities with the
error reporting in fib6_rules (message ID
<20130727060802.GD20273@order.stressinduktion.org>) that might interfere with
the function of my patch; perhaps his change should be applied as well?  I've
reposted his changes with git format-patch as message ID
<20130730065258.GG13357@zirkel.wertarbyte.de> ("[PATCH v2 1/2] fib6_rules: make
error handling consistent with IPv4").
