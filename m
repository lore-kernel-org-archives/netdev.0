From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V3 8/8] net: backlog functions rename
Date: Fri, 05 Mar 2010 07:32:15 +0100
Message-ID: <1267770735.2867.9.camel@edumazet-laptop>
References: <1267761707-15605-1-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-2-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-3-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-4-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-5-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-6-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-7-git-send-email-yi.zhu@intel.com>
	 <1267761707-15605-8-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f219.google.com ([209.85.220.219]:41944 "EHLO
	mail-fx0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab0CEGc0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 01:32:26 -0500
Received: by fxm19 with SMTP id 19so3728957fxm.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 22:32:23 -0800 (PST)
In-Reply-To: <1267761707-15605-8-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 05 mars 2010 =C3=A0 12:01 +0800, Zhu Yi a =C3=A9crit :
> sk_add_backlog -> __sk_add_backlog
> sk_add_backlog_limited -> sk_add_backlog
>=20
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
>  include/net/sock.h       |    6 +++---
>  net/core/sock.c          |    2 +-
>  net/dccp/minisocks.c     |    2 +-
>  net/ipv4/tcp_ipv4.c      |    2 +-
>  net/ipv4/tcp_minisocks.c |    2 +-
>  net/ipv4/udp.c           |    2 +-
>  net/ipv6/tcp_ipv6.c      |    2 +-
>  net/ipv6/udp.c           |    4 ++--
>  net/llc/llc_c_ac.c       |    2 +-
>  net/llc/llc_conn.c       |    2 +-
>  net/sctp/input.c         |    4 ++--
>  net/tipc/socket.c        |    2 +-
>  net/x25/x25_dev.c        |    2 +-
>  13 files changed, 17 insertions(+), 17 deletions(-)
>=20

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


