From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:phy:dp83640: Initialize PTP clocks at device init.
Date: Tue, 04 Feb 2014 20:08:14 -0800 (PST)
Message-ID: <20140204.200814.1817351670764606951.davem@davemloft.net>
References: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48786 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753768AbaBEEIO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:08:14 -0500
In-Reply-To: <1391438218-21994-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Mon,  3 Feb 2014 15:36:58 +0100

> The trigger and events functionality can be useful even if packet
> timestamping is not used, but the required PTP clock is only enabled
> when packet timestamping is started. This patch moves the clock enabl=
e
> to when the interface is configured.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied.
