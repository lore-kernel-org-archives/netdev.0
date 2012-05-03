From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 1/3] tcp: early retransmit: tcp_enter_recovery()
Date: Wed, 02 May 2012 20:56:22 -0400 (EDT)
Message-ID: <20120502.205622.805216286970252257.davem@davemloft.net>
References: <1336001404-21879-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, ncardwell@google.com,
	nanditad@google.com, netdev@vger.kernel.org
To: ycheng@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753456Ab2ECA4d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 20:56:33 -0400
In-Reply-To: <1336001404-21879-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yuchung Cheng <ycheng@google.com>
Date: Wed,  2 May 2012 16:30:02 -0700

> This a prepartion patch that refactors the code to enter recovery
> into a new function tcp_enter_recovery(). It's needed to implement
> the delayed fast retransmit in ER.
> 
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Applied.
