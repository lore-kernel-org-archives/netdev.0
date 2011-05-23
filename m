From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5] caif: Bugfix add check NULL pointer before calling
 functions.
Date: Sun, 22 May 2011 20:13:29 -0400 (EDT)
Message-ID: <20110522.201329.705740464807691861.davem@davemloft.net>
References: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52722 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754340Ab1EWAOR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2011 20:14:17 -0400
In-Reply-To: <1306099134-12989-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun, 22 May 2011 23:18:50 +0200

> Add check on layer->dn !=3D NULL before calling functions in
> layer below.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
