From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] net: sctp: minor: make sctp_ep_common's
 member 'dead' a bool
Date: Mon, 15 Apr 2013 14:14:11 -0400 (EDT)
Message-ID: <20130415.141411.1985602595839232527.davem@davemloft.net>
References: <1366032438-4412-1-git-send-email-dborkman@redhat.com>
	<1366032438-4412-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34793 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756201Ab3DOSON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Apr 2013 14:14:13 -0400
In-Reply-To: <1366032438-4412-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Mon, 15 Apr 2013 15:27:18 +0200

> Since dead only holds two states (0,1), make it a bool instead
> of a 'char', which is more appropriate for its purpose.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
