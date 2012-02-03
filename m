From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] Implement IP_UNICAST_IF socket option.
Date: Thu, 02 Feb 2012 20:51:31 -0500 (EST)
Message-ID: <20120202.205131.327673308271585980.davem@davemloft.net>
References: <CAEU2+vrgxzTmiHWs-kVoKeu2_DcFZQBjCXwQfQ8dms5O6+Larg@mail.gmail.com>
	<1328222744.2480.38.camel@edumazet-laptop>
	<CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: ehoover@mines.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48024 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754172Ab2BCBve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2012 20:51:34 -0500
In-Reply-To: <CAEU2+vrtwSUKgY1f44h8btcKnhvhBHUU-d_BkkyYx+E1KViQ+g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Erich E. Hoover" <ehoover@mines.edu>
Date: Thu, 2 Feb 2012 18:22:51 -0700

> I though I should double check this, and apparently I missed that
> there's an equivalent IPV6_UNICAST_IF on "other OS".  Should that be a
> patch 2 or should it be included in this one?

I'm ambivalent, you can do it either way as far as I'm concerned.
