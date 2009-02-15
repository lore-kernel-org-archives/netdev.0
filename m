From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 09/43] drivers/net/r6040.c: fix sparse warning: Using plain integer as NULL pointer
Date: Sun, 15 Feb 2009 15:00:06 +0100
Message-ID: <200902151500.06516.florian@openwrt.org>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211400.23489.24726.stgit@vmbox.hanneseder.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Hannes Eder <hannes@hanneseder.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f161.google.com ([209.85.218.161]:43545 "EHLO
	mail-bw0-f161.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752275AbZBOOAQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2009 09:00:16 -0500
In-Reply-To: <20090214211400.23489.24726.stgit@vmbox.hanneseder.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Hannes,

Le Saturday 14 February 2009 22:14:04 Hannes Eder, vous avez =C3=A9crit=
=C2=A0:
> Fix this sparse warnings:
>   drivers/net/r6040.c:487:31: warning: Using plain integer as NULL po=
inter
>   drivers/net/r6040.c:492:31: warning: Using plain integer as NULL po=
inter

Good catch, thanks.
>
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>

Acked-by: Florian Fainelli <florian@openwrt.org>
--=20
Best regards, Florian Fainelli
Email : florian@openwrt.org
http://openwrt.org
-------------------------------
