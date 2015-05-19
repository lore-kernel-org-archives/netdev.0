From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] switchdev: don't abort hardware ipv4 fib
 offload on failure to program fib entry in hardware
Date: Tue, 19 May 2015 16:28:45 -0400 (EDT)
Message-ID: <20150519.162845.955021778058631119.davem@davemloft.net>
References: <555AD11E.5040709@cumulusnetworks.com>
	<20150519.123418.481170679256206928.davem@davemloft.net>
	<20150519194731.GK9559@gospo.home.greyhouse.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	sfeldma@gmail.com, john.fastabend@gmail.com, jiri@resnulli.us,
	netdev@vger.kernel.org
To: gospo@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750993AbbESU2u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2015 16:28:50 -0400
In-Reply-To: <20150519194731.GK9559@gospo.home.greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@cumulusnetworks.com>
Date: Tue, 19 May 2015 15:47:32 -0400

> Are you actually saying that if users complain loudly enough about
> the current behavior (not the change Roopa has proposed) that you
> would be open to considering a change the current behavior?

I am saying that we have a contract with users not to break existing
behavior.  Full stop.
