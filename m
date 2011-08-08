From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] bonding: document two undocumented options.
Date: Sun, 07 Aug 2011 22:16:40 -0700 (PDT)
Message-ID: <20110807.221640.1477501421754835279.davem@davemloft.net>
References: <3571.1312405193@death>
	<1312650399-5165-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:52622 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751106Ab1HHFQq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2011 01:16:46 -0400
In-Reply-To: <1312650399-5165-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Sat,  6 Aug 2011 19:06:39 +0200

> Commit 655f8919d549ad1872e24d826b6ce42530516d2e
>     bonding: add min links parameter to 802.3ad
>=20
> and commit ebd8e4977a87cb81d93c62a9bff0102a9713722f
>     bonding: add all_slaves_active parameter
>=20
> introduced new options to bonding, but didn't provide the documentati=
on
> for those options.
>=20
> V2: add the default value for both options.
> V3: document the exact behavior of min_links default value.
>=20
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied, thanks.
