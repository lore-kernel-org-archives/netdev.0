From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: PATCH Question, Firewall mark inherit for ip6_tunnel
Date: Mon, 19 Sep 2011 12:32:04 +0200
Message-ID: <1316428324.2539.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D903109@ESESSCMS0356.eemea.ericsson.se>
	 ,<1316424324.2539.6.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90310A@ESESSCMS0356.eemea.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hans =?ISO-8859-1?Q?Schillstr=F6m?=
	<hans.schillstrom@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:51730 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755118Ab1ISKby (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2011 06:31:54 -0400
Received: by eya28 with SMTP id 28so1466235eya.19
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2011 03:31:53 -0700 (PDT)
In-Reply-To: <C8A6796DE7C66C4ABCBC18106CB6C1CC106D90310A@ESESSCMS0356.eemea.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 19 septembre 2011 =C3=A0 11:52 +0200, Hans Schillstr=C3=B6m a =
=C3=A9crit :

> Thanks Eric,
> Do you take care of the user mode  part as well (i.ie ip commad)

Yes, I'll send the iproute2 part as well.
