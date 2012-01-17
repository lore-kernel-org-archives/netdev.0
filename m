From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fix NULL-deref in WARN() in skb_gso_segment()
Date: Tue, 17 Jan 2012 15:48:04 -0500 (EST)
Message-ID: <20120117.154804.290049443178263185.davem@davemloft.net>
References: <a9312f6addc77e2af43ef4e1cceb91676944ae3d.1326829994.git.mirq-linux@rere.qmqm.pl>
	<1326831785.2478.22.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org, joe@perches.com
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57815 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751550Ab2AQUsP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 15:48:15 -0500
In-Reply-To: <1326831785.2478.22.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 17 Jan 2012 20:23:05 +0000

> On Tue, 2012-01-17 at 21:00 +0100, Micha=A9=A9 Miros=A9=A9aw wrote:
>> Bug was introduced in commit c8f44affb7244f2ac3e703cab13d55ede27621b=
b.
>=20
> Sorry, this conflicts with changes I've just submitted, the first of
> which has already been applied.

I'll sort this out.
