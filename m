From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next-2.6 1/3 (TAKE 3 RESENT)] ipv6 mcast: Introduce
 include/net/mld.h for MLD definitions.
Date: Thu, 8 Apr 2010 09:47:53 -0700
Message-ID: <20100408094753.596bb61c@nehalam>
References: <201004080659.o386xIXP019382@94.43.138.210.xn.2iij.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34229 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758745Ab0DHQsB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 12:48:01 -0400
In-Reply-To: <201004080659.o386xIXP019382@94.43.138.210.xn.2iij.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Is there a piece missing. I tried this against net-next-2.6


--=20
  CC [M]  net/ipv6/mcast.o
net/ipv6/mcast.c: In function =E2=80=98igmp6_event_query=E2=80=99:
net/ipv6/mcast.c:1134: error: implicit declaration of function =E2=80=98=
mld_msg=E2=80=99
net/ipv6/mcast.c:1134: warning: assignment makes pointer from integer w=
ithout a cast
net/ipv6/mcast.c: In function =E2=80=98igmp6_event_report=E2=80=99:
net/ipv6/mcast.c:1254: warning: assignment makes pointer from integer w=
ithout a cast
