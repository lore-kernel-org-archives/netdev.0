From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 0/3] net: extend netdevice notifier and use
 it for flags change
Date: Tue, 28 May 2013 13:11:15 -0700 (PDT)
Message-ID: <20130528.131115.1864952244875016179.davem@davemloft.net>
References: <1369740623-17601-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, timo.teras@iki.fi,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, bhutchings@solarflare.com,
	xiyou.wangcong@gmail.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51141 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755546Ab3E1ULQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 16:11:16 -0400
In-Reply-To: <1369740623-17601-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jiri Pirko <jiri@resnulli.us>
Date: Tue, 28 May 2013 13:30:20 +0200

> Jiri Pirko (2):
>   net: pass info struct via netdevice notifier
>   net: pass changed flags along with NETDEV_CHANGE event
>=20
> Timo Ter=E4s (1):
>   arp: flush arp cache on IFF_NOARP change

Looks great, applied, thanks Jiri!
