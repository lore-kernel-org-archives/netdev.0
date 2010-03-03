From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bridge] [PATCH]  bridge: per-cpu packet statistics (v3)
Date: Wed, 03 Mar 2010 07:09:04 +0100
Message-ID: <1267596544.2839.71.camel@edumazet-laptop>
References: <20100301161658.5a61143b@nehalam>
	 <1267520579.2964.27.camel@edumazet-laptop>
	 <20100302095831.151c8bb5@nehalam> <1267553173.2839.9.camel@edumazet-laptop>
	 <20100302153209.74742a96@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f212.google.com ([209.85.218.212]:64339 "EHLO
	mail-bw0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751195Ab0CCGJK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 01:09:10 -0500
Received: by bwz4 with SMTP id 4so740913bwz.28
        for <netdev@vger.kernel.org>; Tue, 02 Mar 2010 22:09:08 -0800 (PST)
In-Reply-To: <20100302153209.74742a96@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 02 mars 2010 =C3=A0 15:32 -0800, Stephen Hemminger a =C3=A9cri=
t :
> The shared packet statistics are a potential source of slow down
> on bridged traffic. Convert to per-cpu array, but only keep those
> statistics which change per-packet.
>=20
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>=20

Thanks Stephen !

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>


