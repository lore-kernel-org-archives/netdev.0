From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL] arcnet: fixes and features
Date: Fri, 23 Jun 2017 13:54:03 -0400 (EDT)
Message-ID: <20170623.135403.778221185468261150.davem@davemloft.net>
References: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel@pengutronix.de
To: m.grzeschik@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34628 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754343AbdFWRyK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2017 13:54:10 -0400
In-Reply-To: <20170622153110.4079-1-m.grzeschik@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <m.grzeschik@pengutronix.de>
Date: Thu, 22 Jun 2017 17:31:02 +0200

> are available in the git repository at:
> 
>   public@git.pengutronix.de:/mgr/linux.git tags/arcnet-for-mainline

I'm not pulling from that address, either setup a properl kernel.org
GIT account or we work with just plain patches.

Next, you need to provide a proper commit message in a
"[PATCH 0/N] " posting explaining at a high level what
the patch series is doing as a unit, how it is doing it,
and why it is doing it that way.

Finally, in patch #1 the assignment of "flags" to "0" in the
declaration is unnecessary please remove it.
