From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ixgbe: Fix TX stats accounting
Date: Wed, 25 Nov 2009 10:31:32 +0100
Message-ID: <4B0CF974.2070702@gmail.com>
References: <20091123064630.7385.30498.stgit@ppwaskie-hc2.jf.intel.com>	 <19210.54486.353397.804028@gargle.gargle.HOWL>	 <4B0ABF6D.9000103@gmail.com>	 <Pine.WNT.4.64.0911231525180.10056@ppwaskie-MOBL2.amr.corp.intel.com>	 <4B0B8F52.3010005@gmail.com> <1259053673.2631.30.camel@ppwaskie-mobl2>	 <4B0BADA6.7080602@gmail.com> <1259057164.2631.36.camel@ppwaskie-mobl2>	 <4B0BC56D.1000909@gmail.com> <4B0BDE3E.2020406@gmail.com> <9929d2390911242338m6c4b322dod7a8af4c3c386d56@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	"robert@herjulf.net" <robert@herjulf.net>,
	Jesper Dangaard Brouer <hawk@diku.dk>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60460 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758418AbZKYJbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Nov 2009 04:31:34 -0500
In-Reply-To: <9929d2390911242338m6c4b322dod7a8af4c3c386d56@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Kirsher a =C3=A9crit :
>=20
> Thanks Eric.  I have added the patch to my tree for testing and revie=
w.
>=20

Thanks Jeff, a similar problem on RX stats should also be addressed.

Is your tree public ?

