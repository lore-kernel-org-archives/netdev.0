From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: add a wrapper for tcp_sock->pred_flags
Date: Wed, 15 May 2013 14:38:37 -0700 (PDT)
Message-ID: <20130515.143837.2240552073318996143.davem@davemloft.net>
References: <9196da039b33675c3c053d934d92b9f6d2f7e197.1368540390.git.wpan@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, panweiping3@gmail.com
To: wpan@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33755 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752054Ab3EOVii (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 17:38:38 -0400
In-Reply-To: <9196da039b33675c3c053d934d92b9f6d2f7e197.1368540390.git.wpan@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Weiping Pan <wpan@redhat.com>
Date: Tue, 14 May 2013 22:07:15 +0800

> From: Weiping Pan <panweiping3@gmail.com>
> 
> I think a wrapper is more meaningful here than the assignment.
> 
> Signed-off-by: Weiping Pan <wpan@redhat.com>

This is just syntactic folly, I'm not applying this, sorry.
