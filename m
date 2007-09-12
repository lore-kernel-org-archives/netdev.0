From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: 2.6.23-rc6: known regressions with patches
Date: Wed, 12 Sep 2007 19:08:25 +0200
Message-ID: <1189616905.3570.59.camel@shinybook.infradead.org>
References: <46E81AE2.8030802@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Gabriel C <nix.or.die@googlemail.com>,
	Satyam Sharma <satyam.sharma@gmail.com>,
	Vitaly Bordug <vitb@kernel.crashing.org>,
	Kay Sievers <kay.sievers@vrfy.org>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Greg KH <gregkh@suse.de>,
	Anssi Hannula <anssi.hannula@gmail.com>,
	Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>,
	netdev@vger.kernel.org, Christian Kujau <lists@nerdbynature.de>,
	jamal <hadi@cyberus.ca>, linux-usb-devel@lists.sourceforge.net,
	sean@mess.org, Adrian Bunk <bunk@kernel.org>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:41933 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764893AbXILRIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 13:08:48 -0400
In-Reply-To: <46E81AE2.8030802@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-09-12 at 18:59 +0200, Michal Piotrowski wrote:
> MTD
>=20
> Subject         : include/linux/mtd/map.h:128:2: error: #error "No bu=
s width supported. What's the point?"
> References      : http://lkml.org/lkml/2007/9/11/151
> Last known good : ?
> Submitter       : Toralf F=C3=B6rster <toralf.foerster@gmx.de>
> Caused-By       : ?
> Handled-By      : ?
> Patch           : http://git.infradead.org/?p=3Dmtd-2.6.git;a=3Dcommi=
t;h=3D241651d04d672fb685b2874707016cbbf95931e5
> Status          : patch available

Didn't you already _drop_ this from your list of regressions once?

--=20
dwmw2

