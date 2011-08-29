From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: relax PKTINFO non local ipv6 udp xmit check
Date: Sun, 28 Aug 2011 21:06:33 -0400 (EDT)
Message-ID: <20110828.210633.783157755808327582.davem@davemloft.net>
References: <20110828.171154.1746224796788156557.davem@davemloft.net>
	<1314570931-6233-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: maze@google.com, netdev@vger.kernel.org, ek@google.com,
	lorenzo@google.com
To: zenczykowski@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44539 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750926Ab1H2BGk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2011 21:06:40 -0400
In-Reply-To: <1314570931-6233-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =AFenczykowski <zenczykowski@gmail.com>
Date: Sun, 28 Aug 2011 15:35:31 -0700

> From: Maciej =AFenczykowski <maze@google.com>
>=20
> Allow transparent sockets to be less restrictive about
> the source ip of ipv6 udp packets being sent.
>=20
> Google-Bug-Id: 5018138
> Signed-off-by: Maciej =AFenczykowski <maze@google.com>

Applied, thanks a lot.
