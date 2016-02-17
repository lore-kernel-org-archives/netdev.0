From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net,stable] qmi_wwan: add "4G LTE usb-modem U901"
Date: Tue, 16 Feb 2016 20:39:59 -0500 (EST)
Message-ID: <20160216.203959.445270828966872945.davem@davemloft.net>
References: <1455291734-29233-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	tschaefer@t-online.de
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42702 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964799AbcBQBkB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 20:40:01 -0500
In-Reply-To: <1455291734-29233-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Fri, 12 Feb 2016 16:42:14 +0100

> Thomas reports:
>=20
> T:  Bus=3D01 Lev=3D01 Prnt=3D01 Port=3D03 Cnt=3D01 Dev#=3D  4 Spd=3D4=
80 MxCh=3D 0
> D:  Ver=3D 2.00 Cls=3D00(>ifc ) Sub=3D00 Prot=3D00 MxPS=3D64 #Cfgs=3D=
  1
> P:  Vendor=3D05c6 ProdID=3D6001 Rev=3D00.00
> S:  Manufacturer=3DUSB Modem
> S:  Product=3DUSB Modem
> S:  SerialNumber=3D1234567890ABCDEF
> C:  #Ifs=3D 5 Cfg#=3D 1 Atr=3De0 MxPwr=3D500mA
> I:  If#=3D 0 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Dr=
iver=3Doption
> I:  If#=3D 1 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Dr=
iver=3Doption
> I:  If#=3D 2 Alt=3D 0 #EPs=3D 2 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Dr=
iver=3Doption
> I:  If#=3D 3 Alt=3D 0 #EPs=3D 3 Cls=3Dff(vend.) Sub=3Dff Prot=3Dff Dr=
iver=3Dqmi_wwan
> I:  If#=3D 4 Alt=3D 0 #EPs=3D 2 Cls=3D08(stor.) Sub=3D06 Prot=3D50 Dr=
iver=3Dusb-storage
>=20
> Reported-by: Thomas Sch=E4fer <tschaefer@t-online.de>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied and queued up for -stable, thanks.
