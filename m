From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-2.6] net: add skb_dst_force() in
 sock_queue_err_skb()
Date: Wed, 18 May 2011 16:34:46 +0200
Message-ID: <1305729286.2991.31.camel@edumazet-laptop>
References: <1305673846.6741.35.camel@edumazet-laptop>
	 <20110518.022151.1670373958008022789.davem@davemloft.net>
	 <20110518142519.GH3539@smp.if.uj.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Witold Baryluk <baryluk@smp.if.uj.edu.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64920 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757208Ab1EROev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 10:34:51 -0400
Received: by fxm17 with SMTP id 17so1248300fxm.19
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 07:34:50 -0700 (PDT)
In-Reply-To: <20110518142519.GH3539@smp.if.uj.edu.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 18 mai 2011 =C3=A0 16:25 +0200, Witold Baryluk a =C3=A9crit=
 :

> Patch solves problem for me.
>=20
> Initial warning was looking harmless anyway to me,
> but good it is fixed now.

It was a real bug, thanks for reporting it and testing the fix.


