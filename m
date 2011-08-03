From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: document two undocumented options.
Date: Wed, 03 Aug 2011 03:44:25 -0700 (PDT)
Message-ID: <20110803.034425.1421983987148421662.davem@davemloft.net>
References: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fubar@us.ibm.com, andy@greyhouse.net, netdev@vger.kernel.org
To: nicolas.2p.debian@free.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56107 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753639Ab1HCKob convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Aug 2011 06:44:31 -0400
In-Reply-To: <1312315615-5739-1-git-send-email-nicolas.2p.debian@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>
Date: Tue,  2 Aug 2011 22:06:55 +0200

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
> Signed-off-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Please explicitly mention in each new entry what the default
setting is.

Thanks.
