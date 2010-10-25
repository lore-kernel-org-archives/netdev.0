From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 21:56:52 +0200
Message-ID: <1288036613.2451.2.camel@edumazet-laptop>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de>
	 <4CC5A301.1080606@lwfinger.net> <1288021905.2826.142.camel@edumazet-laptop>
	 <4CC5C863.9070801@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Hannemann <arnd@arndnet.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:42126 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757555Ab0JYT5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Oct 2010 15:57:23 -0400
In-Reply-To: <4CC5C863.9070801@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 25 octobre 2010 =C3=A0 13:11 -0500, Larry Finger a =C3=A9crit =
:

> I have no idea why that header was included - likely historical in th=
e
> transformation from bcm43xx to b43legacy. For completeness, there are=
 2 more
> places to change:

Anyway, Arnd patch is fine by me, I didnt want to supply an alternate
patch.

I only was wondering why the include was in this driver...

