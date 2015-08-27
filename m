From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/3] mlxsw: expose EMAD transactions
 statistics via debugfs
Date: Wed, 26 Aug 2015 23:01:15 -0700 (PDT)
Message-ID: <20150826.230115.2076911912997875741.davem@davemloft.net>
References: <20150826.104906.9246591425074015.davem@davemloft.net>
	<CAE4R7bDZqrgtzi5dAdCgSxy_hTHE9MPfD1WENX3ea7ZXps7+Mw@mail.gmail.com>
	<20150827054004.GA2228@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sfeldma@gmail.com, netdev@vger.kernel.org, idosch@mellanox.com,
	eladr@mellanox.com, ogerlitz@mellanox.com, jiri@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753107AbbH0GBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Aug 2015 02:01:18 -0400
In-Reply-To: <20150827054004.GA2228@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu, 27 Aug 2015 07:40:04 +0200

> Switch object itselt would not help you to expose rocker internals. I
> don't think that you can find generic way, same for all drivers, to
> expose internal tables and stuff. That is hw specific.

Tables are datastructures with names and types.

Is it not possible to describe datastructures and their types with
user visible interfaces?

Anyone against what I am saying right now is simply lazy.
