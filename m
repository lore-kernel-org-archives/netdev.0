From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3] net: sctp: sctp_verify_init: clean up
 mandatory checks and add comment
Date: Thu, 29 Aug 2013 15:55:27 -0400 (EDT)
Message-ID: <20130829.155527.1331594681514143386.davem@davemloft.net>
References: <1377615232-11412-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37574 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755383Ab3H2Tza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 15:55:30 -0400
In-Reply-To: <1377615232-11412-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 27 Aug 2013 16:53:52 +0200

> Add a comment related to RFC4960 explaning why we do not check for initial
> TSN, and while at it, remove yoda notation checks and clean up code from
> checks of mandatory conditions. That's probably just really minor, but makes
> reviewing easier.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks.
