From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Sat, 5 Jan 2008 07:39:04 +0100
Message-ID: <20080105063904.GC22739@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist> <20080104034357.GA2113@atjola.homenet> <20080104084517.GA21628@rhlx01.hs-esslingen.de> <20080104101740.GA4406@atjola.homenet> <20080104224352.GA7853@rhlx01.hs-esslingen.de> <20080105061002.GA22739@atjola.homenet>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>,
	Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: Andreas Mohr <andi@lisas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:35329 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751686AbYAEGjH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Jan 2008 01:39:07 -0500
Content-Disposition: inline
In-Reply-To: <20080105061002.GA22739@atjola.homenet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.05 07:10:02 +0100, Bj=F6rn Steinbrink wrote:
> - nv_probe sees 00:11:22:00:00:01
> - doesn't match the vendor stuff
> - becomes 01:00:00:22:11:00
>=20
> Oops, that's not quite the expected thing.

Haha, I just noticed that that even is a multicast address, so you'd ge=
t
a random MAC address in that case *lol.

Bj=F6rn
