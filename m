From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, v2] net: release dst entry in dev_hard_start_xmit()
Date: Tue, 19 May 2009 07:44:03 +0200
Message-ID: <4A124723.8010305@cosmosbay.com>
References: <4A092F59.7020900@cosmosbay.com>	<4A093178.9020105@cosmosbay.com>	<4A09CD6B.5070604@cosmosbay.com> <20090518.221956.153457626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, jarkao2@gmail.com, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:39438 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbZESFoH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:44:07 -0400
In-Reply-To: <20090518.221956.153457626.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Tue, 12 May 2009 21:26:35 +0200
>=20
>> [PATCH] net: release dst entry in dev_hard_start_xmit()
>  ...
>> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
>=20
> Applied, thanks Eric.
>=20
> Eric, please followup and double-check the pppoe paths
> that Jarek mentioned.  I never saw that fully resolved.
>=20

Ah OK, I 'll do this David

Thanks !


