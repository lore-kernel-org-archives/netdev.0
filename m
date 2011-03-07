From: David Miller <davem@davemloft.net>
Subject: Re: net: allow handlers to be processed for orig_dev
Date: Mon, 07 Mar 2011 15:37:36 -0800 (PST)
Message-ID: <20110307.153736.258104960.davem@davemloft.net>
References: <20110301062631.GC2855@psychotron.redhat.com>
	<4D6CAD33.2090706@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jpirko@redhat.com, netdev@vger.kernel.org,
	shemminger@linux-foundation.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net
To: nicolas.2p.debian@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756512Ab1CGXg7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Mar 2011 18:36:59 -0500
In-Reply-To: <4D6CAD33.2090706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com>
Date: Tue, 01 Mar 2011 09:24:19 +0100

> Le 01/03/2011 07:26, Jiri Pirko a =E9crit :
>> This was there before, I forgot about this. Allows deliveries to
>> ptype_base handlers registered for orig_dev. I presume this is still
>> desired.
>=20
> Yes, it is. Sorry for missing it in my review.
>=20
>> Signed-off-by: Jiri Pirko<jpirko@redhat.com>
>=20
> Reviewed-by: Nicolas de Peslo=FCan <nicolas.2p.debian@free.fr>

Applied, thanks.
