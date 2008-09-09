From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [IPv6] "sendmsg: invalid argument" to multicast group after some time
Date: Tue, 09 Sep 2008 08:52:05 +0200
Message-ID: <63ca0b47d6921cd641bb3ca26ab20baa@chewa.net>
References: <20080902150008.GD7289@schleppi.birkenwald.de> <OF604A6380.9CF7D18A-ON882574BF.000171B8-882574BF.00031DB5@us.ibm.com> <20080909003852.GA20315@pest>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Brian Haley <brian.haley@hp.com>, netdev@vger.kernel.org
To: Bernhard Schmidt <berni@birkenwald.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:41805 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755159AbYIIGwG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:52:06 -0400
In-Reply-To: <20080909003852.GA20315@pest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 9 Sep 2008 02:38:53 +0200, Bernhard Schmidt <berni@birkenwald.d=
e>=0D
wrote:=0D
> ff00::/8 dev teredo  metric 256  mtu 1280 advmss 1220 hoplimit 429496=
7295=0D
               ^^^^^^=0D
Uho... that interface is not multicast-capable. Not sure how the kernel=
=0D
handles the conflicting routes.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont

