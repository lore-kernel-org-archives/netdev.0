From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: icmp: include addresses in debug
 messages
Date: Mon, 26 Oct 2015 22:00:11 -0700 (PDT)
Message-ID: <20151026.220011.2046305730652987603.davem@davemloft.net>
References: <1445688020-8510-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35664 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750920AbbJ0Enc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 00:43:32 -0400
In-Reply-To: <1445688020-8510-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Sat, 24 Oct 2015 14:00:20 +0200

> Messages like "icmp6_send: no reply to icmp error" are close
> to useless. Adding source and destination addresses to provide
> some more clue.
>=20
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

This is fine, applied, thanks.
