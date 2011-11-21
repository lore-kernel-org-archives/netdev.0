From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch] fix error handle in ip_mc_add_src()
Date: Mon, 21 Nov 2011 17:00:00 +0100
Message-ID: <1321891200.10470.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1321890701.14281.51.camel@barry.pixelworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	David Stevens <dlstevens@us.ibm.com>
To: Jun Zhao <mypopydev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:33823 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610Ab1KUQAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 11:00:05 -0500
Received: by bke11 with SMTP id 11so6732114bke.19
        for <netdev@vger.kernel.org>; Mon, 21 Nov 2011 08:00:03 -0800 (PST)
In-Reply-To: <1321890701.14281.51.camel@barry.pixelworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 21 novembre 2011 =C3=A0 23:51 +0800, Jun Zhao a =C3=A9crit :
> from: Jun Zhao <mypopydev@gmail.com>
>=20
> When add sources to interface failure, need to roll back the sfcount[=
MODE]=20
> to before state. We need to match it corresponding.=20
>=20
> Signed-off-by: Jun Zhao <mypopydev@gmail.com>

Thanks !

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
