From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv10] macvlan: add source mode
Date: Tue, 01 Apr 2014 15:27:15 -0400 (EDT)
Message-ID: <20140401.152715.540804712598274734.davem@davemloft.net>
References: <1396284485-17914-1-git-send-email-michael-dev@fami-braun.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org,
	projekt-wlan@fem.tu-ilmenau.de
To: michael-dev@fami-braun.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54204 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751439AbaDAT1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2014 15:27:16 -0400
In-Reply-To: <1396284485-17914-1-git-send-email-michael-dev@fami-braun.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Braun <michael-dev@fami-braun.de>
Date: Mon, 31 Mar 2014 18:48:05 +0200

> This patch adds a new mode of operation to macvlan, called "source".
> It allows one to set a list of allowed mac address, which is used
> to match against source mac address from received frames on underlying
> interface.

Unfortunately this new feature came in too late and I'm going to have
to defer this to the next merge window, please resubmit after net-next
is reopenned.

Thanks!
