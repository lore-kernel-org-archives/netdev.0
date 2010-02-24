From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: tuntap with =?UTF-8?Q?tun=5Fno=5Fpi=20and=20X=32=35=20question?=
Date: Wed, 24 Feb 2010 13:51:44 +0100
Message-ID: <1bf329b2b4fe8fca4f4ea16874643c11@chewa.net>
References: <d45a3acc1002240352r43e546c7x4a40aa7d8e187369@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>
To: andrew hendry <andrew.hendry@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:40821 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756844Ab0BXMvp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2010 07:51:45 -0500
In-Reply-To: <d45a3acc1002240352r43e546c7x4a40aa7d8e187369@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Wed, 24 Feb 2010 22:52:27 +1100, andrew hendry <andrew.hendry@gmail.=
com>=0D
wrote:=0D
> The 0x40 and 0x60 comes from the first byte of the IP which has the=0D
> version there?=0D
=0D
Yes.=0D
=0D
> With X.25 the first byte changes depending on the call sequence, so i=
t=0D
> cant be detected and set in the same way.=0D
=0D
Then you need to use PI. That's what it's meant for.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

