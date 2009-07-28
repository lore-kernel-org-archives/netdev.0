From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next-2.6 phonet causes build error
Date: Tue, 28 Jul 2009 08:18:40 +0200
Message-ID: <4A6E9840.7020308@gmail.com>
References: <4A6D512A.1050504@gmail.com>	<200907271106.02456.remi.denis-courmont@nokia.com>	<4A6D60B4.1070601@cosmosbay.com> <20090727.193157.168527559.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: remi.denis-courmont@nokia.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:59649 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753150AbZG1GSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jul 2009 02:18:51 -0400
In-Reply-To: <20090727.193157.168527559.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Mon, 27 Jul 2009 10:09:24 +0200
>=20
>> I currently use gcc-3.4.6, and current net-next-2.6 doesnt compile
>> for me (but linux-2.6 does compile properly so I just know this is
>> already fixed upstream)
>=20
> Eric, just FYI, I am not going to merge Linus's tree into
> net-2.6 (and therefore not into net-next-2.6 either) unless
> there is some conflict to resolve.
>=20
> So if you need this build fix, please integrate it locally
> by whatever means works best for you.

Thanks for the info David :)

Dont worry, I can deal with it !
