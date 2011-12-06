From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] caif-spi: Bugfix for dump upon device removal
Date: Tue, 06 Dec 2011 13:34:40 -0500 (EST)
Message-ID: <20111206.133440.760673631224783027.davem@davemloft.net>
References: <1323192305-10843-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, erwan.bracq@stericsson.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60383 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752632Ab1LFSep convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:34:45 -0500
In-Reply-To: <1323192305-10843-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue,  6 Dec 2011 18:25:05 +0100

> From: Erwan Bracq <erwan.bracq@stericsson.com>
>=20
> Fix dump upon device removal, by moving deinitialization from
> platform-device-remove to network-interface-uninit.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks.
