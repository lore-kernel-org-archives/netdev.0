From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] net: Handle gso packets in dev_forward_skb
Date: Mon, 21 Mar 2011 15:00:56 -0700
Message-ID: <m1hbawi15z.fsf@fess.ebiederm.org>
References: <m1wrjsi2tf.fsf@fess.ebiederm.org>
	<1300743744.2837.7.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Ben Greear <greearb@candelatech.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:39928 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976Ab1CUWBM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 18:01:12 -0400
In-Reply-To: <1300743744.2837.7.camel@edumazet-laptop> (Eric Dumazet's message
	of "Mon, 21 Mar 2011 22:42:24 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> Hmm, did you follow http://patchwork.ozlabs.org/patch/86815/
> discussion ?

No.  It seems I missed it, but I do have the same problem, and
essentially the same fix. 

Eric
