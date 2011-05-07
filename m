From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: PROBLEM: IPv6 Duplicate Address Detection with non
 RFC-conform ICMPv6 packets
Date: Sat, 07 May 2011 16:06:22 +0200
Message-ID: <1304777182.2821.1262.camel@edumazet-laptop>
References: <4DC54157.9010306@computer.org>
	 <1304773802.2821.1214.camel@edumazet-laptop>
	 <dc9a790de083b31ff85c0b9578c980e7@mail.insa-lyon.fr>
	 <1304774758.2821.1237.camel@edumazet-laptop>
	 <842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Ceuleers <jan.ceuleers@computer.org>, netdev@vger.kernel.org
To: Gervais Arthur <arthur.gervais@insa-lyon.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60142 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955Ab1EGOG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 10:06:26 -0400
Received: by wya21 with SMTP id 21so2985034wya.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 07:06:25 -0700 (PDT)
In-Reply-To: <842648e0f4a8c6f7cd8a47cd6916a939@mail.insa-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 07 mai 2011 =C3=A0 15:54 +0200, Gervais Arthur a =C3=A9crit :

> Why would the victim itself claim already having the IPv6 address?
>=20

Why should it care ? Please point me the RFC saying its illegal to send
or receive a frame with SRC_MAC =3D=3D DST_MAC





