From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] cdc_ncm and cdc_mbim fixes for 3.8
Date: Mon, 21 Jan 2013 14:22:42 -0500 (EST)
Message-ID: <20130121.142242.2240250911008731906.davem@davemloft.net>
References: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	gsuarez@smithmicro.com, alexey.orishko@stericsson.com,
	oneukum@suse.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752685Ab3AUTWo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 14:22:44 -0500
In-Reply-To: <1358783440-11459-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 21 Jan 2013 16:50:37 +0100

> The 2 first patches in this series are required to make the Sierra
> Wireless MC7710 card work in MBIM mode.  They may also be
> required for other Qualcomm firmware based MBIM devices.
>=20
> Patch #1 was previously posted as a standalone patch.  This version
> is a replacement, removing a theoretical NULL pointer exception.=20
>=20
> Patch #3 fixes a bug I introduced in v3.7

All applied, thanks.
