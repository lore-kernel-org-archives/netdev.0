From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH net-next-2.6] bnx2x: Remove two prefetch()
Date: Wed, 28 Apr 2010 08:36:14 -0400
Message-ID: <1272458174.14068.16.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272018366.7895.7930.camel@edumazet-laptop>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xiaosuo@gmail.com,
	therbert@google.com, shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:44347 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751342Ab0D1MgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 08:36:17 -0400
Received: by pwj9 with SMTP id 9so10221821pwj.19
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 05:36:17 -0700 (PDT)
In-Reply-To: <1272458001.2267.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-04-28 at 14:33 +0200, Eric Dumazet wrote:

> If you wait a bit, I have another patch to speedup udp receive path ;)

Shoot whenever you are ready ;-> I will test with and without your
patch..

cheers,
jamal

