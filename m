From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bnx2x: properly update skb when mtu > 1500
Date: Tue, 13 Dec 2011 13:31:18 -0500 (EST)
Message-ID: <20111213.133118.198800923714432490.davem@davemloft.net>
References: <1323769253-8760-1-git-send-email-dmitry@broadcom.com>
	<1323770177.2307.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dmitry@broadcom.com, netdev@vger.kernel.org, eilong@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49580 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752330Ab1LMSb1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2011 13:31:27 -0500
In-Reply-To: <1323770177.2307.2.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 13 Dec 2011 10:56:17 +0100

> Le mardi 13 d=E9cembre 2011 =E0 11:40 +0200, Dmitry Kravkov a =E9crit=
 :
>> Since commit e52fcb2462ac484e6dd6e68869536609f0216938 newly allocate=
d
>> skb for small packets are not updated properly and dropped by stack.
>>=20
>> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
 ...
> Ah, sorry for this, thanks for fixing it !
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
