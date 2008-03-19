From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: build #428 gcc warning for v2.6.25-rc6-74-g264e3e8 in net/3c523.c
 and boot/a20.c
Date: Wed, 19 Mar 2008 06:11:26 -0700
Message-ID: <47E110FE.5010405@zytor.com>
References: <200803191028.19462.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	James Bottomley <jJames.Bottomley@HansenPartnership.com>
To: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:48491 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750781AbYCSTYN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 15:24:13 -0400
In-Reply-To: <200803191028.19462.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Toralf F=F6rster wrote:
> Hello,
>=20
> the build with the attached .config was successful, however I got :
>=20
> drivers/net/3c523.c:583: warning: 'cleanup_card' defined but not used
> drivers/net/3c509.c:729: warning: 'el3_device_remove' defined but not=
 used
> arch/x86/boot/a20.c74: warning: 'a20_test_short' defined but not used
> arch/x86/boot/a20.c:81: warning: 'a20_test_long' defined but not used
> arch/x86/boot/a20.c:86: warning: 'enable_a20_bios' defined but not us=
ed
> arch/x86/boot/a20.c:103: warning: 'enable_a20_fast' defined but not u=
sed
>=20

> CONFIG_X86_VOYAGER=3Dy

Not really surprising, being Voyager.

	-hpa

