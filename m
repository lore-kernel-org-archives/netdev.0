From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] packet: minor: add generic tpacket_uhdr to
 access packet headers
Date: Tue, 16 Apr 2013 16:40:05 -0400 (EDT)
Message-ID: <20130416.164005.282889837292815375.davem@davemloft.net>
References: <1366113466-17071-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49791 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965211Ab3DPUkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 16:40:08 -0400
In-Reply-To: <1366113466-17071-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Tue, 16 Apr 2013 13:57:46 +0200

> There is no need to add a dozen unions each time at the start
> of the function. So, do this once and use it instead. Thus, we
> can remove some duplicate code and make it more readable.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied.
