From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2 4/6] mlxsw: core: Implement temperature
 hwmon interface
Date: Wed, 02 Dec 2015 17:28:47 -0500 (EST)
Message-ID: <20151202.172847.1855287186918935450.davem@davemloft.net>
References: <20151129104918.GC2194@nanopsycho.orion>
	<CAJ3xEMhGv9nTq+CtpX=e4E+4WpipVnc---EUOEqxJ06xOSBsog@mail.gmail.com>
	<20151202222551.GP2355@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51555 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756924AbbLBW2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 17:28:49 -0500
In-Reply-To: <20151202222551.GP2355@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Wed, 2 Dec 2015 23:25:52 +0100

> Again, there is no possible way to achieve this bugon, other than a
> stack corruption. I don't think we should try to cope with a stack
> corruption.

Then remove the assertion.
