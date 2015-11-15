From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Sun, 15 Nov 2015 17:03:29 -0500 (EST)
Message-ID: <20151115.170329.1968169017632328612.davem@davemloft.net>
References: <CAHp75VehDXoMNsXD08Et9Z5Pds+7Xf5+PXHE2pFzh4Srs-Tw+A@mail.gmail.com>
	<20151115.125905.63907005203700143.davem@davemloft.net>
	<201511152104.59206.linux@rainbow-software.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy.shevchenko@gmail.com, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org
To: linux@rainbow-software.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54376 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751560AbbKOWDj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Nov 2015 17:03:39 -0500
In-Reply-To: <201511152104.59206.linux@rainbow-software.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ondrej Zary <linux@rainbow-software.org>
Date: Sun, 15 Nov 2015 21:04:58 +0100

> Tested it with D-Link DGE-550T (chip marked DL-2000, probably
> rebranded TC9020) and it works fine.  Even the TC9020 datasheet
> says: "Access Rule: Word, Double Word". So it was always wrong but
> worked anyway.

Great, thanks for the info.
