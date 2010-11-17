From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: move definitions of BPF_S_* to net/core/filter.c
Date: Wed, 17 Nov 2010 07:38:39 +0100
Message-ID: <1289975919.2732.199.camel@edumazet-laptop>
References: <1289975304-19796-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51235 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933297Ab0KQGip (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Nov 2010 01:38:45 -0500
Received: by mail-wy0-f174.google.com with SMTP id 28so1630293wyb.19
        for <netdev@vger.kernel.org>; Tue, 16 Nov 2010 22:38:44 -0800 (PST)
In-Reply-To: <1289975304-19796-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 novembre 2010 =C3=A0 14:28 +0800, Changli Gao a =C3=A9cr=
it :
> BPF_S_* are used internally, should not be exposed to the others.
>=20
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>



