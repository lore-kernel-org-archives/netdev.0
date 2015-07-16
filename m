From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Fix finding best source address in
 ipv6_dev_get_saddr().
Date: Wed, 15 Jul 2015 21:07:17 -0700 (PDT)
Message-ID: <20150715.210717.43770639330208104.davem@davemloft.net>
References: <55A3CAFA.3060404@miraclelinux.com>
	<CALx6S34Bj_YtRqqL5U0zJ9RKEu_Uvp9zYyNJLgvjEqX9jNrYqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org,
	ek@google.com, thehajime@gmail.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750720AbbGPEHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 00:07:20 -0400
In-Reply-To: <CALx6S34Bj_YtRqqL5U0zJ9RKEu_Uvp9zYyNJLgvjEqX9jNrYqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Mon, 13 Jul 2015 08:31:05 -0700

> I am testing this patch which may be a little simpler. Also idev needs
> to be checked after __in6_dev_get

Tom, I'm applying Hideaki's fix for now.

If you want to simplify the code, feel free to submit that as a
follow-up, thank you!
