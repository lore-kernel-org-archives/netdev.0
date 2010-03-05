From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 3/8] udp: use limited socket backlog
Date: Fri, 05 Mar 2010 07:21:13 +0100
Message-ID: <1267770073.2867.2.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:51807 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752710Ab0CEGVT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:21:19 -0500
Received: by fxm19 with SMTP id 19so3723146fxm.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:21:17 -0800 (PST)
In-Reply-To: <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 12:01 +0800, Zhu Yi a =C3=A9crit :
> Make udp adapt to the limited socket backlog change.
>=20
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  net/ipv4/udp.c |    6 ++++--
>  net/ipv6/udp.c |   28 ++++++++++++++++++----------
>  2 files changed, 22 insertions(+), 12 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


