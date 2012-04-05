From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] team: add loadbalance mode
Date: Wed, 04 Apr 2012 20:31:25 -0400 (EDT)
Message-ID: <20120404.203125.393095943302356939.davem@davemloft.net>
References: <1333577787-878-1-git-send-email-jpirko@redhat.com>
	<1333577787-878-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51361 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753898Ab2DEAcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 20:32:33 -0400
In-Reply-To: <1333577787-878-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu,  5 Apr 2012 00:16:27 +0200

> This patch introduces new team mode. It's TX port is selected by
> user-set BPF hash function.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thanks Jiri.
