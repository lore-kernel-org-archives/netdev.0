From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: qmi_wwan: support Sierra Wireless MC77xx devices
 in QMI mode
Date: Thu, 19 Apr 2012 15:33:08 -0400 (EDT)
Message-ID: <20120419.153308.2068714446413918789.davem@davemloft.net>
References: <1334691503-31787-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51777 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756400Ab2DSTeR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 15:34:17 -0400
In-Reply-To: <1334691503-31787-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Tue, 17 Apr 2012 21:38:23 +0200

> The MC77xx devices can operate in two modes: "Direct IP" or "QMI",
> switchable using a password protected AT command.  Both product ID
> and USB interface configuration will change when switched.
>=20
> The "sierra_net" driver supports the "Direct IP" mode.  This driver
> supports the "QMI" mode.
>=20
> There are also multiple possible USB interface configurations in each
> mode, some providing more than one wwan interface.  Like many other
> devices made for Windows, different interface types are identified
> using a static interface number.  We define a Sierra specific
> interface whitelist to support this.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thank you.
