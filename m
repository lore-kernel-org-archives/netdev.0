From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 6/8] tipc: use limited socket backlog
Date: Fri, 05 Mar 2010 07:30:25 +0100
Message-ID: <1267770625.2867.7.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-6-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jon Maloy <jon.maloy@ericsson.com>,
	Allan Stephens <allan.stephens@windriver.com>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:35702 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab0CEGaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:30:30 -0500
Received: by fg-out-1718.google.com with SMTP id l26so109745fgb.1
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:30:29 -0800 (PST)
In-Reply-To: <1267761707-15605-6-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 12:01 +0800, Zhu Yi a =C3=A9crit :
> Make tipc adapt to the limited socket backlog change.
>=20
> Cc: Jon Maloy <jon.maloy@ericsson.com>
> Cc: Allan Stephens <allan.stephens@windriver.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  net/tipc/socket.c |    6 ++++--
>  1 files changed, 4 insertions(+), 2 deletions(-)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


