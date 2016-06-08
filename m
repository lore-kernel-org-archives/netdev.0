From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net_sched: add missing paddattr description
Date: Wed, 8 Jun 2016 15:37:03 +0200
Message-ID: <57581F7F.4020507@6wind.com>
References: <1465391985.7945.4.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37414 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404AbcFHNhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 09:37:07 -0400
Received: by mail-wm0-f48.google.com with SMTP id k204so17552115wmk.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 06:37:06 -0700 (PDT)
In-Reply-To: <1465391985.7945.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 08/06/2016 15:19, Eric Dumazet a =C3=A9crit :
> From: Eric Dumazet <edumazet@google.com>
>=20
> "make htmldocs" complains otherwise:
>=20
> .//net/core/gen_stats.c:65: warning: No description found for paramet=
er 'padattr'
> .//net/core/gen_stats.c:101: warning: No description found for parame=
ter 'padattr'
>=20
>=20
> Fixes: 9854518ea04d ("sched: align nlattr properly when needed")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>
Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Thanks Eric.
