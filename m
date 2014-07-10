From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dp83640: Always decode received status frames
Date: Wed, 09 Jul 2014 17:01:23 -0700 (PDT)
Message-ID: <20140709.170123.670690749424659365.davem@davemloft.net>
References: <1403700016-11398-1-git-send-email-stefan.sorensen@spectralink.com>
	<1404801588.2494.5.camel@e37108.spectralink.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: Stefan.Sorensen@spectralink.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34696 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753407AbaGJABY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2014 20:01:24 -0400
In-Reply-To: <1404801588.2494.5.camel@e37108.spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: S=F8rensen, Stefan <Stefan.Sorensen@spectralink.com>
Date: Tue, 8 Jul 2014 06:39:52 +0000

> On Wed, 2014-06-25 at 14:40 +0200, Stefan S=F8rensen wrote:
>> Currently status frames are only handled when packet timestamping is
>> enabled, but status frames are also needed for pin event timestampin=
g.
>>=20
>> Fix by moving packet timestamping check to after status frame decode=
=2E
>>=20
>> Signed-off-by: Stefan S=F8rensen <stefan.sorensen@spectralink.com>
>=20
> Dave, I have noticed that this patch is marked as superseded in
> patchworks (http://patchwork.ozlabs.org/patch/363989/), though I have
> not posted any updated patch and only response is an Acked-By from
> Richard.

Sorry about that, applied, thanks.
