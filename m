From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 0/7] bonding: introduce bonding options
 Netlink support
Date: Sat, 19 Oct 2013 18:59:47 -0400 (EDT)
Message-ID: <20131019.185947.507215908086684979.davem@davemloft.net>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40366 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab3JSW7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 18:59:54 -0400
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 18 Oct 2013 17:43:32 +0200

> This patchset basically allows "mode" and "active_slave" bonding options
> to be propagated and set up via standart RT Netlink interface.
> 
> In future other options can be easily added as well.

Nice work Jiri, series applied, thanks.
