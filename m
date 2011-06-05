From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] ep93xx-eth: convert to phylib
Date: Sun, 5 Jun 2011 20:29:24 +0200
Message-ID: <201106052029.24742.f.fainelli@gmail.com>
References: <201106051957.36492.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Lennert Buytenhek <kernel@wantstofly.org>,
	Mika Westerberg <mika.westerberg@iki.fi>,
	hsweeten@visionengravers.com, ryan@bluewatersys.com,
	linux-arm-kernel@lists.infradead.org, davem@davemloft.net
To: netdev@vger.kernel.org, Herbert Valerio Riedel <hvr@gnu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:48025 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab1FES33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2011 14:29:29 -0400
Received: by wya21 with SMTP id 21so2338904wya.19
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2011 11:29:28 -0700 (PDT)
In-Reply-To: <201106051957.36492.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 05 June 2011 19:57:36 Florian Fainelli wrote:
> ep93xx-eth lacked support for monitoring link status changes, with this
> patch, link changes are now watched and reported correctly.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>
> ---

I just stumbled upon: http://www.mail-
archive.com/netdev@vger.kernel.org/msg62549.html
which does not seem to have been merged.

I will respin my patch with Herbert's changes
--
Florian
