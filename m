From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: 3com: typhoon: use new api
 ethtool_{get|set}_link_ksettings
Date: Wed, 02 Nov 2016 15:27:21 -0400 (EDT)
Message-ID: <20161102.152721.349225928048079403.davem@davemloft.net>
References: <1478041911-22188-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dave@thedillows.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: tremyfr@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45602 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756023AbcKBT1X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2016 15:27:23 -0400
In-Reply-To: <1478041911-22188-1-git-send-email-tremyfr@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com>
Date: Wed,  2 Nov 2016 00:11:51 +0100

> The ethtool api {get|set}_settings is deprecated.
> We move this driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>

Applied.
