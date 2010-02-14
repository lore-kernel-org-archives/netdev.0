From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: linux-2..6.33-rc7 and b43
Date: Sun, 14 Feb 2010 16:38:33 -0600
Message-ID: <4B787B69.7040307@lwfinger.net>
References: <4B77C819.9050602@mandriva.org> <4B782670.9080001@lwfinger.net> 	<4B784498.8030509@mandriva.org> <69e28c911002141059y57fb2097x5613c25ad1c616da@mail.gmail.com> 	<4B784C68.8020402@mandriva.org> <69e28c911002141353x7805033fl2e68ae56f3dabf40@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Backlund <tmb@mandriva.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?G=E1bor_Stefanik?= <netrolller.3d@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f201.google.com ([209.85.223.201]:62222 "EHLO
	mail-iw0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751382Ab0BNWig (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Feb 2010 17:38:36 -0500
In-Reply-To: <69e28c911002141353x7805033fl2e68ae56f3dabf40@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/14/2010 03:53 PM, G=E1bor Stefanik wrote:
>=20
> Looks like the trigger is not Intel Atom, but PhoenixBIOS after all -
> a quick analysis of bios v. A15 for this machine shows it to be a
> highly cloaked/rebranded PhoenixBIOS.
>=20
> Core 2 T7250 is a regular Merom/Santa Rosa CPU, almost the same as my
> T7100 (only the clock multiplier is different), and is not a ULV CPU,
> the trigger we previously suspected.
>=20
> PhoenixBIOS (and its rebrands) appears to be the common trigger.

It also requires an Intel CPU. My AMD is fine with a Phoenix BIOS.

Larry

