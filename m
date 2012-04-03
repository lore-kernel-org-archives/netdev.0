From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 1/4] filter: Allow to create sk-unattached
 filters
Date: Tue, 03 Apr 2012 18:36:45 -0400 (EDT)
Message-ID: <20120403.183645.510151560994882796.davem@davemloft.net>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
	<1333227682-10235-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39073 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753519Ab2DCWh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:37:57 -0400
In-Reply-To: <1333227682-10235-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 31 Mar 2012 23:01:19 +0200

> Today, BPF filters are bind to sockets. Since BPF machine becomes handy
> for other purposes, this patch allows to create unattached filter.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
