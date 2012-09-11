From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] [PATCH] net: qmi_wwan: fix Gobi device probing for
 un2430
Date: Tue, 11 Sep 2012 01:10:19 -0400 (EDT)
Message-ID: <20120911.011019.60823716275206979.davem@davemloft.net>
References: <1347296579-15692-1-git-send-email-pierre.sauter@gmail.com>
	<20120910.164314.1674016370550788813.davem@davemloft.net>
	<22bf77fd-e0de-4a07-acf2-cd816a543ee9@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pierre.sauter@gmail.com, gregkh@linuxfoundation.org,
	netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37733 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab2IKFKY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 01:10:24 -0400
In-Reply-To: <22bf77fd-e0de-4a07-acf2-cd816a543ee9@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 11 Sep 2012 06:59:57 +0200

> David Miller <davem@davemloft.net> wrote:
>=20
>>From: pierre.sauter@gmail.com
>>Date: Mon, 10 Sep 2012 19:02:59 +0200
>>
>>> From: Pierre Sauter <pierre.sauter@gmail.com>
>>>=20
>>> HP un2430 is a Gobi 3000 device. It was mistakenly treated as Gobi
>>1000
>>> in patch b9f90eb2740203ff2592efe640409ad48335d1c2.
>>>=20
>>> I own this device and qmi_wwan works again with this fix.
>>>=20
>>> Signed-off-by: Pierre Sauter <pierre.sauter@gmail.com>
>>
>>Bjorn, ACK/NACK?
>=20
> Acked-by: Bj=F8rn Mork <bjorn@mork.no>
>=20
> Thanks for fixing this, Pierre. I wonder how I managed to get this
> wrong. Better look it all over again, I guess...

Applied, thanks everyone.
