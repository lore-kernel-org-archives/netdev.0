From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: Kernel panic (network stack)
Date: Fri, 12 Oct 2007 10:20:45 -0700
Message-ID: <20071012102045.3f181605@freepuppy.rosehill>
References: <200710121635.40414.xeb@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:44654 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762850AbXJLRU7 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 13:20:59 -0400
In-Reply-To: <200710121635.40414.xeb@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 12 Oct 2007 16:35:40 +0400
xeb@mail.ru wrote:

>=20
> ----------  =D0=9F=D0=B5=D1=80=D0=B5=D1=81=D0=BB=D0=B0=D0=BD=D0=BD=D0=
=BE=D0=B5 =D1=81=D0=BE=D0=BE=D0=B1=D1=89=D0=B5=D0=BD=D0=B8=D0=B5  -----=
-----
>=20
> =D0=A2=D0=B5=D0=BC=D0=B0: Kernel panic (network stack)
> =D0=94=D0=B0=D1=82=D0=B0: 12 =D0=BE=D0=BA=D1=82=D1=8F=D0=B1=D1=80=D1=8F=
 2007
> =D0=9E=D1=82=D0=BF=D1=80=D0=B0=D0=B2=D0=B8=D1=82=D0=B5=D0=BB=D1=8C: x=
eb@mail.ru
> =D0=BF=D0=BE=D0=BB=D1=83=D1=87=D0=B0=D1=82=D0=B5=D0=BB=D1=8C:  linux-=
kernel@vger.kernel.org
>=20
> Hello!
> I develop network driver.
> It works fine while less then 100 network interfaces exists.
> Then i give kernel panic. What could cause it ?
>=20

Since it probably in your code. Please code (or place to download)
the driver code.

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
