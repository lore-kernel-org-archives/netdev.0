From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] netprio_cgroup.h: dont include module.h from other
 includes
Date: Tue, 24 Jan 2012 23:04:02 +0100
Message-ID: <1327442642.2767.2.camel@edumazet-laptop>
References: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nhorman@tuxdriver.com, davem@davemloft.net, netdev@vger.kernel.org,
	jdb@comx.dk
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:51651 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515Ab2AXWEH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 17:04:07 -0500
Received: by wgbed3 with SMTP id ed3so4536244wgb.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 14:04:06 -0800 (PST)
In-Reply-To: <1327440799-1057-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 24 janvier 2012 =C3=A0 16:33 -0500, Paul Gortmaker a =C3=A9cri=
t :
> A considerable effort was invested in wiping out module.h
> from being present in all the other standard includes.  This
> one leaked back in, but once again isn't strictly necessary,
> so remove it.
>=20
> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
