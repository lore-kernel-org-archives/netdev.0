From: Alkis Georgopoulos <alkisg@gmail.com>
Subject: Re: Bypass flow control problems
Date: Wed, 29 Dec 2010 10:47:15 +0200
Message-ID: <1293612435.1813.9.camel@alkis>
References: <1293040291.1777.36.camel@alkis>
	 <20101227134346.GD2754@reaktio.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Pasi =?ISO-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:43504 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751105Ab0L2IrU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Dec 2010 03:47:20 -0500
Received: by bwz15 with SMTP id 15so10762024bwz.19
        for <netdev@vger.kernel.org>; Wed, 29 Dec 2010 00:47:18 -0800 (PST)
In-Reply-To: <20101227134346.GD2754@reaktio.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=CE=A3=CF=84=CE=B9=CF=82 27-12-2010, =CE=B7=CE=BC=CE=AD=CF=81=CE=B1 =CE=
=94=CE=B5=CF=85, =CE=BA=CE=B1=CE=B9 =CF=8E=CF=81=CE=B1 15:43 +0200, =CE=
=BF/=CE=B7 Pasi K=C3=A4rkk=C3=A4inen
=CE=AD=CE=B3=CF=81=CE=B1=CF=88=CE=B5:
> You could set up QoS rules on the server to limit the network speed p=
er client..

That sounds promising. I'll try to limit the rate of packages that the
server sends to each client to 90 Mbps and see if that works around the
flow control problem. Any tips for a good method to do that?

Thank you.

