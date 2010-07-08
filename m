From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] cxgb4: fix for new ndo_get_stats64 signature
Date: Thu, 08 Jul 2010 07:17:10 +0200
Message-ID: <1278566230.2543.0.camel@edumazet-laptop>
References: <1278555085-17074-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:61229 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234Ab0GHFRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jul 2010 01:17:14 -0400
Received: by wyf23 with SMTP id 23so249007wyf.19
        for <netdev@vger.kernel.org>; Wed, 07 Jul 2010 22:17:13 -0700 (PDT)
In-Reply-To: <1278555085-17074-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 07 juillet 2010 =C3=A0 19:11 -0700, Dimitris Michailidis a
=C3=A9crit :
> The change to ndo_get_stats64 in "net: fix 64 bit counters on 32 bit =
arches"
> missed cxgb4.  Fix it.
>=20
> Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
> ---

Indeed, sorry and thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


