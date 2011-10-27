From: David Miller <davem@davemloft.net>
Subject: Re: asix usb network driver: nfg
Date: Wed, 26 Oct 2011 22:17:19 -0400 (EDT)
Message-ID: <20111026.221719.2216112919297458522.davem@davemloft.net>
References: <4EA89972.5060101@teksavvy.com>
	<20111026.194045.2019668159403582571.davem@davemloft.net>
	<4EA8B283.3010105@teksavvy.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kernel@teksavvy.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751077Ab1J0CRZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Oct 2011 22:17:25 -0400
In-Reply-To: <4EA8B283.3010105@teksavvy.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Lord <kernel@teksavvy.com>
Date: Wed, 26 Oct 2011 21:23:15 -0400

> Any strong advance objections to replacing the in-kernel version
> with a (fixed) vendor open source version?

It need to meet the coding etc. standards for inclusion, last
time I looked at it their driver indeed need a bit of cleaning
up.

It's a sad situation, they started with the upstream driver and
just hacked on it however they pleased in their private copy.
So now we have this huge divergance and no effort on their part
to rectify things.
