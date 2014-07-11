From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] dp83640: Adjust ptp event timestamps
Date: Fri, 11 Jul 2014 14:05:27 -0700 (PDT)
Message-ID: <20140711.140527.366519768057328225.davem@davemloft.net>
References: <1405059506-3996-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org
To: stefan.sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57504 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858AbaGKVF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 17:05:28 -0400
In-Reply-To: <1405059506-3996-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
Date: Fri, 11 Jul 2014 08:18:26 +0200

> From the dp86340 Software Development Guide:
>   Event timestamp values should be adjusted by 3*reference clock peri=
od +
>   11 ns =3D 35 ns to compensate for input path and synchronization de=
lays.
>=20
> So subtract 35ns from event timestamps.
>=20
> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
> Acked-by: Richard Cochran <richardcochran@gmail.com>

Applied, thank you.
