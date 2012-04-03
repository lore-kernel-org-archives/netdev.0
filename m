From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 4/4] team: add loadbalance mode
Date: Tue, 03 Apr 2012 18:38:27 -0400 (EDT)
Message-ID: <20120403.183827.537974416471429606.davem@davemloft.net>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
	<1333227682-10235-5-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765Ab2DCWjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:39:37 -0400
In-Reply-To: <1333227682-10235-5-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 31 Mar 2012 23:01:22 +0200

> This patch introduces new team mode. It's TX port is selected by
> user-set BPF hash function.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Please resubmit this once you've fixed up patch #3.
