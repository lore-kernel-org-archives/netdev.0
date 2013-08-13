From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: question about netif_rx
Date: Tue, 13 Aug 2013 07:20:36 +0200
Message-ID: <20130813052036.GA11640@electric-eye.fr.zoreil.com>
References: <alpine.DEB.2.02.1308111151210.2072@localhost6.localdomain6>
 <20130811155640.GA10070@electric-eye.fr.zoreil.com>
 <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: grant.likely@linaro.org, rob.herring@calxeda.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	devicetree@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1308111811440.2072@localhost6.localdomain6>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> :
> Fran=C3=A7ois Romieu <romieu@fr.zoreil.com> :
[...]
> > Can you send a netif_receive_skb replacement patch for it ?
>=20
> Just to be sure, I just replace netif_rx by netif_receive_skb, nothin=
g
> else?

Yes. It should imho be fine with a comment incluing your analysis and a
few words about the current state of checksum offloading support.

--=20
Ueimor
