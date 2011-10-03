From: David Miller <davem@davemloft.net>
Subject: Re: [patch v2] caif: add error handling for allocation
Date: Mon, 03 Oct 2011 13:46:11 -0400 (EDT)
Message-ID: <20111003.134611.1100932218414818334.davem@davemloft.net>
References: <CAJK669Yb6V=xr9ZvQGOKGEvmzO1JGhrHD+sR69b04EQxUjOOrQ@mail.gmail.com>
	<20110921072159.GJ4999@elgon.mountain>
	<81C3A93C17462B4BBD7E272753C105791D2BC1882D@EXDCVYMBSTM005.EQ1STM.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dan.carpenter@oracle.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50127 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932244Ab1JCRqT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 13:46:19 -0400
In-Reply-To: <81C3A93C17462B4BBD7E272753C105791D2BC1882D@EXDCVYMBSTM005.EQ1STM.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur BRENDELAND <sjur.brandeland@stericsson.com>
Date: Fri, 23 Sep 2011 12:38:45 +0200

> [Dan]:=20
>> The allocation of "phyinfo" wasn't checked, and also the allocation
>> wasn't freed on error paths.  Sjur Br=E6ndeland pointed out as well
>> that "phy_driver" should be freed on the error path too.
>>=20
>> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
>=20
> Looks good, thank you Dan.
> Acked-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied, thanks.
