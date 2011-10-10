From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] af_packet: remove unnecessary BUG_ON() in
 tpacket_destruct_skb
Date: Mon, 10 Oct 2011 19:05:04 +0200
Message-ID: <1318266304.3227.18.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20111010185246.15533bv1p3pmnba6@mail.your-server.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: danborkmann@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:45474 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751866Ab1JJRFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Oct 2011 13:05:01 -0400
Received: by gyg10 with SMTP id 10so5534842gyg.19
        for <netdev@vger.kernel.org>; Mon, 10 Oct 2011 10:05:01 -0700 (PDT)
In-Reply-To: <20111010185246.15533bv1p3pmnba6@mail.your-server.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 10 octobre 2011 =C3=A0 18:52 +0200, danborkmann@iogearbox.net =
a
=C3=A9crit :
> If skb is NULL, then stack trace is thrown anyway on dereference.
> Therefore, the stack trace triggered by BUG_ON is duplicate.
>=20
> Signed-off-by: Daniel Borkmann <danborkmann@googlemail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>


Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks
