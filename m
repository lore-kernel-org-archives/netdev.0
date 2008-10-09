From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] tcpv6: convert opt[] -> topt in tcp_v6_send_reset
Date: Thu, 09 Oct 2008 14:42:12 -0700 (PDT)
Message-ID: <20081009.144212.11592204.davem@davemloft.net>
References: <1223544937-12595-1-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1223544937-12595-2-git-send-email-ilpo.jarvinen@helsinki.fi>
	<1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37960
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755182AbYJIVmg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 17:42:36 -0400
In-Reply-To: <1223544937-12595-3-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu,  9 Oct 2008 12:35:36 +0300

> after this I get:
>=20
> $ diff-funcs tcp_v6_send_reset tcp_ipv6.c tcp_ipv6.c tcp_v6_send_ack
>  --- tcp_ipv6.c:tcp_v6_send_reset()
>  +++ tcp_ipv6.c:tcp_v6_send_ack()

Applied.
