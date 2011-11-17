From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next 2/2] team: avoid using variable-length array
Date: Thu, 17 Nov 2011 13:40:22 -0500 (EST)
Message-ID: <20111117.134022.653641656780834689.davem@davemloft.net>
References: <1321539365-1125-2-git-send-email-jpirko@redhat.com>
	<1321540278.2751.40.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20111117151031.GA3209@minipsycho>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	bhutchings@solarflare.com, shemminger@vyatta.com,
	andy@greyhouse.net, fbl@redhat.com, jzupka@redhat.com,
	ivecera@redhat.com, mirqus@gmail.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57536 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754162Ab1KQSkb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2011 13:40:31 -0500
In-Reply-To: <20111117151031.GA3209@minipsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Thu, 17 Nov 2011 16:10:32 +0100

> Sure, I'll do this in separate patch.

No, you'll do it in _this_ patch.

Jiri, please stop resisting the incorporation of feedback into
the patches you post.  You've done this twice in the past 3 days
and it's really irritating.
