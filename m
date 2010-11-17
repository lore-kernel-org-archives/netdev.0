From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH] net: add priority field to pktgen
Date: Wed, 17 Nov 2010 06:27:17 +0100
Message-ID: <1289971637.2732.83.camel@edumazet-laptop>
References: <20101117051228.19479.8267.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37501 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996Ab0KQF1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 00:27:23 -0500
Received: by wyb28 with SMTP id 28so1593230wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 21:27:22 -0800 (PST)
In-Reply-To: <20101117051228.19479.8267.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 novembre 2010 =C3=A0 21:12 -0800, John Fastabend a =C3=A9cr=
it :
> Add option to set skb priority to pktgen. Useful for testing
> QOS features. Also by running pktgen on the vlan device the
> qdisc on the real device can be tested.
>=20
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


