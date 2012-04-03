From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/4] filter: add XOR operation
Date: Tue, 03 Apr 2012 18:36:53 -0400 (EDT)
Message-ID: <20120403.183653.1457760856826993536.davem@davemloft.net>
References: <1333227682-10235-1-git-send-email-jpirko@redhat.com>
	<1333227682-10235-3-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	raise.sail@gmail.com, nuno.martins@caixamagica.pt, matt@ozlabs.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:39078 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755683Ab2DCWiC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 18:38:02 -0400
In-Reply-To: <1333227682-10235-3-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 31 Mar 2012 23:01:20 +0200

> Add XOR instruction fo BPF machine. Needed for computing packet hashes.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Looks good, applied.
