From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Add TCP_NO_DELAYED_ACK socket option
Date: Thu, 27 Oct 2011 14:13:17 +0200
Message-ID: <1319717597.2601.28.camel@edumazet-laptop>
References: <fc8b00b9978b4f956fa705badfaa138854abf919.1319595687.git.luto@amacapital.net>
	 <1319711072.2601.18.camel@edumazet-laptop>
	 <CAEnQRZAmDMg943uufpwf4dj0vw9hfsRu3RFRG+LEqfT2Y0ty1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Lutomirski <luto@amacapital.net>, netdev@vger.kernel.org
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:57133 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754497Ab1J0MN1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Oct 2011 08:13:27 -0400
Received: by ggnb1 with SMTP id b1so2557713ggn.19
        for <netdev@vger.kernel.org>; Thu, 27 Oct 2011 05:13:27 -0700 (PDT)
In-Reply-To: <CAEnQRZAmDMg943uufpwf4dj0vw9hfsRu3RFRG+LEqfT2Y0ty1Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 octobre 2011 =C3=A0 14:54 +0300, Daniel Baluta a =C3=A9crit=
 :

> Few days ago, in our custom kernel we made TCP Delack segments and
> TCP Delack timeout parameters tunable via proc entries.
> Increasing tcp_delack_segs (number of full sized segments that must
> be received until an ACK is sent) we observed an improvement of
> throughput up to 20% in some test cases.
>=20
> Do you think that this kind of patch would have a chance to be
> included in mainstream?
>=20

If your patches are ready, why not sending them as RFC ?
