From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 2/8] tcp: use limited socket backlog
Date: Fri, 05 Mar 2010 07:19:32 +0100
Message-ID: <1267769972.2867.1.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:40862 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525Ab0CEGTj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:19:39 -0500
Received: by fg-out-1718.google.com with SMTP id l26so107575fgb.1
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:19:37 -0800 (PST)
In-Reply-To: <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 12:01 +0800, Zhu Yi a =C3=A9crit :
> Make tcp adapt to the limited socket backlog change.
>=20
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: "Pekka Savola (ipv6)" <pekkas@netcore.fi>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll submit a followup patch to add a MIB counter if your patch gets in=
=2E



