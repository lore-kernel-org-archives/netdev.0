From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: IPv6 routing requests ignore NLM_F_CREATE and NLM_F_REPLACE
Date: Tue, 18 Oct 2011 08:54:28 +0200
Message-ID: <1318920868.2571.52.camel@edumazet-laptop>
References: <82C9FC7ED59434458AD4E09AFF2DE230B534F9@FIESEXC006.nsn-intra.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Vaittinen, Matti (EXT-Other - FI/Oulu)"
	<matti.vaittinen.ext@nsn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:41036 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320Ab1JRGyc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Oct 2011 02:54:32 -0400
Received: by wyg36 with SMTP id 36so237039wyg.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 23:54:31 -0700 (PDT)
In-Reply-To: <82C9FC7ED59434458AD4E09AFF2DE230B534F9@FIESEXC006.nsn-intra.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 18 octobre 2011 =C3=A0 09:02 +0300, Vaittinen, Matti (EXT-Othe=
r -
=46I/Oulu) a =C3=A9crit :
> Hi again.
>=20
=2E..
> I do not intend pushing this topic but is this the correct list to as=
k
> this? Is there something I could clarify regarding my question? If th=
is
> is not correct list, could someone please point me the right one.
>=20

Well, this is the correct list. And yes, please send us a patch.

IPv6 lacks some features found in IPv4, not on purpose, but because
nobody wanted them or had the time to implement them.
