From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]tcp: document tcp_max_ssthresh (Limited Slow-Start)
Date: Sun, 20 Feb 2011 11:10:34 -0800 (PST)
Message-ID: <20110220.111034.189709921.davem@davemloft.net>
References: <4D60C849.40905@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org, jheffner@psc.edu
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42339
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752991Ab1BTTJ6 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Feb 2011 14:09:58 -0500
In-Reply-To: <4D60C849.40905@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Shan Wei <shanwei@cn.fujitsu.com>
Date: Sun, 20 Feb 2011 15:52:41 +0800

> From: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Base on Ilpo's patch about documenting tcp_max_ssthresh.
> (see http://marc.info/?l=3Dlinux-netdev&m=3D117950581307310&w=3D2)
>=20
> According to errata of RFC3742, fix the number of segments increased=20
> during RTT time.=20
>=20
> Just to state the occasion to use this parameter, But
> about how to set parameter value, maybe some others can do it.=20
>=20
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
