From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/3 v3] phy: allow flagging PHY devices as internal
Date: Sat, 25 May 2013 23:36:14 -0700 (PDT)
Message-ID: <20130525.233614.1065887557816421262.davem@davemloft.net>
References: <1369307473-20696-1-git-send-email-f.fainelli@gmail.com>
	<201305242231.11632.f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, afleming@freescale.com, jogo@openwrt.org,
	bhutchings@solarflare.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44692 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754657Ab3EZGgP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 May 2013 02:36:15 -0400
In-Reply-To: <201305242231.11632.f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 24 May 2013 22:31:11 +0100

> Ben,
>=20
> Le jeudi 23 mai 2013 12:11:10, Florian Fainelli a =E9crit :
>> David, Andy,
>>=20
>> This small patch set updates libphy to allow PHY drivers to flag a
>> specific PHY device as internal, which is then used to accurately
>> report the transceiver type (internal vs external) in ethtool.
>=20
> Does the first patch works for you or you do want me to be more descr=
iptive?

I'll apply this series once Ben gets a change to look it over.
