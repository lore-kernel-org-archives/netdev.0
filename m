From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:phy:dp83640: Declare that TX timestamping possible
Date: Tue, 04 Feb 2014 20:08:02 -0800 (PST)
Message-ID: <20140204.200802.1744067878442584024.davem@davemloft.net>
References: <1391438195-21888-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbaBEEID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Feb 2014 23:08:03 -0500
In-Reply-To: <1391438195-21888-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Mon,  3 Feb 2014 15:36:35 +0100

> Set the SKBTX_IN_PROGRESS bit in tx_flags dp83640_txtstamp when doing
> tx timestamps as per Documentation/networking/timestamping.txt.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>

Applied.
