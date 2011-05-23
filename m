From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/5] caif: Fix freezes when running CAIF loopback device
Date: Sun, 22 May 2011 20:13:50 -0400 (EDT)
Message-ID: <20110522.201350.1909963745163033484.davem@davemloft.net>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
	<1306099134-12989-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52708 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752271Ab1EWAN4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:13:56 -0400
In-Reply-To: <1306099134-12989-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun, 22 May 2011 23:18:52 +0200

> Fix spinlock bugs when running out of link-ids in loopback tests and
> avoid allocating link-id when error is set in link-setup-response.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
