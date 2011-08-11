From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Documentation/networking/scaling.txt
Date: Thu, 11 Aug 2011 18:31:19 +0200
Message-ID: <1313080279.3261.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1312899648.5889.14.camel@gopher.nyc.corp.google.com>
	 <4E418030.2010102@hp.com>
	 <CA+FuTSfCp+Ju6YAGvPUzkLXiMFqV8XZV_SOueW5bwxeaeD1vng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, rdunlap@xenotime.net,
	linux-doc@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org, therbert@google.com
To: Will de Bruijn <willemb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:54963 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab1HKQbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 12:31:19 -0400
In-Reply-To: <CA+FuTSfCp+Ju6YAGvPUzkLXiMFqV8XZV_SOueW5bwxeaeD1vng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 11 ao=C3=BBt 2011 =C3=A0 10:26 -0400, Will de Bruijn a =C3=A9c=
rit :

>=20
> I'll be happy to revise it once more. This version also lacks the
> required one-line description in Documentation/networking/00-INDEX, s=
o
> I will have to resubmit, either way.
>=20

Well, patch was already accepted by David in net tree two days ago ;)

You can make changes, but it must be against what was committed.

commit 56c07271307b4a20802005692b2b70dfe13d72e8
Author: Willem de Bruijn <willemb@google.com>
Date:   Tue Aug 9 04:20:48 2011 +0000

    net: add Documentation/networking/scaling.txt
   =20
    Describes RSS, RPS, RFS, accelerated RFS, and XPS.
   =20
    This version incorporates comments by Randy Dunlap and Rick Jones.
    Besides text cleanup, it adds an explicit "Suggested Configuration"
    heading to each section.
   =20
    Signed-off-by: Willem de Bruijn <willemb@google.com>
    Acked-By: Rick Jones <rick.jones2@hp.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>


