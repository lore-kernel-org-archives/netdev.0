From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: fix tcp_rcv_rtt_update() use of an unscaled RTT
 sample
Date: Tue, 10 Apr 2012 17:07:49 -0400 (EDT)
Message-ID: <20120410.170749.354288312321198124.davem@davemloft.net>
References: <1334080760-968-1-git-send-email-ncardwell@google.com>
	<20120410.144737.1047745906309843732.davem@davemloft.net>
	<CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, netdev@vger.kernel.org, nanditad@google.com,
	ycheng@google.com, edumazet@google.com, therbert@google.com
To: dave.taht@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48091 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504Ab2DJVH7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 17:07:59 -0400
In-Reply-To: <CAA93jw5opbBobzkgJ2diRPu2X0aKOsnF9hmcm_LfsLPipeAK7g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@gmail.com>
Date: Tue, 10 Apr 2012 13:46:38 -0700

> awesome, is this needed in stable?

I have it queued up there already.

But you didn't need to write your email at all, you could
have checked this yourself:

http://patchwork.ozlabs.org/user/bundle/2566/?state=*
