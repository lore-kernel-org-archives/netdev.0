From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7 0/4] Support administratively closing application
 sockets
Date: Tue, 15 Dec 2015 23:27:15 -0500 (EST)
Message-ID: <20151215.232715.1457693184238460303.davem@davemloft.net>
References: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, ek@google.com, tom@herbertland.com,
	zenczykowski@gmail.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56617 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754383AbbLPE1R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 23:27:17 -0500
In-Reply-To: <1450236605-87170-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Wed, 16 Dec 2015 12:30:01 +0900

> This patchset adds the ability to administratively close a socket
> without any action from the process owning the socket or the
> socket protocol.

Series applied, thanks for sticking with this.
