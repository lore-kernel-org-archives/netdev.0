From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: e1000 driver problems
Date: Tue, 4 Dec 2007 20:59:41 +0100
Message-ID: <20071204195941.GJ8704@ics.muni.cz>
References: <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz> <47541ED0.9090808@intel.com> <20071204153405.GG8704@ics.muni.cz> <Pine.LNX.4.64.0712041043520.15251@tesla.psc.edu> <20071204170827.GH8704@ics.muni.cz> <47558C0F.9000708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matt Mathis <mathis@psc.edu>, NetDev <netdev@vger.kernel.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:34613 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbXLDUAH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 15:00:07 -0500
Content-Disposition: inline
In-Reply-To: <47558C0F.9000708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 09:19:11AM -0800, Kok, Auke wrote:
> if you "just" want to disable gigabit speed, get the latest ethtool a=
nd run:
>=20
>    ethtool -s eth0 advertise 0x0f
>=20

thanks. You may then let know people behind http://www.lesswatts.org/ t=
o
change tips&tricks related to the network. I turned off autonegotiation
according to that web.

--=20
Luk=E1=B9 Hejtm=E1nek
