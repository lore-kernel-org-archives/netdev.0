From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 2.6.38.x, 2.6.39 sfq? kernel panic in sfq_enqueue
Date: Mon, 23 May 2011 17:05:46 +0200
Message-ID: <1306163146.20687.19.camel@edumazet-laptop>
References: <598fe111e91c6236b8bfdfca323b9a17@visp.net.lb>
	 <1306153938.20687.2.camel@edumazet-laptop>
	 <1306155058.20687.8.camel@edumazet-laptop>
	 <47b6835144d208dca4c6675f6510fcad@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55832 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754099Ab1EWPFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2011 11:05:51 -0400
Received: by wya21 with SMTP id 21so4271683wya.19
        for <netdev@vger.kernel.org>; Mon, 23 May 2011 08:05:50 -0700 (PDT)
In-Reply-To: <47b6835144d208dca4c6675f6510fcad@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 23 mai 2011 =C3=A0 17:27 +0300, Denys Fedoryshchenko a =C3=A9c=
rit :

> > Thanks !
>  By objdump or he must recompile kernel with DEBUG_INFO and use gdb?
>=20
>=20
>=20


Just objdump of sch_sfq.o (or sch_sfq.ko) file, (to keep existing
offsets), thanks




