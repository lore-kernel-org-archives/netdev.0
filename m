From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SFQ on HFSC leaf does not seem to work
Date: Fri, 23 Dec 2011 09:10:08 +0100
Message-ID: <1324627808.10854.6.camel@edumazet-laptop>
References: <1324620022.10184.100.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:57718 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752332Ab1LWIKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2011 03:10:13 -0500
Received: by wgbdr13 with SMTP id dr13so17071044wgb.1
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 00:10:11 -0800 (PST)
In-Reply-To: <1324620022.10184.100.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 d=C3=A9cembre 2011 =C3=A0 01:00 -0500, John A. Sullivan =
III a
=C3=A9crit :

> Where might this 3000 ms delay be coming from?
>=20

Certainly not from SFQ

You could use tcpdump to check if delay is at egress or ingress side.
