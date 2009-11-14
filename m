From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: TCP throughput drops sharply around MTU of 180 bytes
Date: Sat, 14 Nov 2009 10:57:41 +0100
Message-ID: <4AFE7F15.1080504@gmail.com>
References: <51d384e10911140028r76e1aefei3a224b5c542d82e8@mail.gmail.com>	 <4AFE6FF0.3030101@gmail.com> <4AFE748C.3050100@gmail.com> <51d384e10911140124g285621a5n54afa1bdb1b02997@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ang Way Chuang <wcang79@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41399 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753346AbZKNJ5i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Nov 2009 04:57:38 -0500
In-Reply-To: <51d384e10911140124g285621a5n54afa1bdb1b02997@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ang Way Chuang a =E9crit :
> I assume that ip route .... advmss achieves that effect? I tried it,
> but it doesn't work.
>=20

It should. Please provide your kernel version and what you tried exactl=
y.

