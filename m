From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/8] Forget the zero_it argument of sk_alloc()
Date: Thu, 01 Nov 2007 00:41:45 -0700 (PDT)
Message-ID: <20071101.004145.225723193.davem@davemloft.net>
References: <472885B1.7090103@openvz.org>
	<47288A34.7010207@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35399
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754355AbXKAHlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 03:41:46 -0400
In-Reply-To: <47288A34.7010207@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Wed, 31 Oct 2007 16:59:16 +0300

> Finally, the zero_it argument can be completely removed from
> the callers and from the function prototype.
> 
> Besides, fix the checkpatch.pl warnings about using the
> assignments inside if-s.
> 
> This patch is rather big, and it is a part of the previous one.
> I splitted it wishing to make the patches more readable. Hope 
> this particular split helped.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
