From: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an anycast address
Date: Mon, 17 Feb 2014 11:52:51 -0800 (PST)
Message-ID: <1392666771.65203.YahooMailNeo@web125503.mail.ne1.yahoo.com>
References: <CAMrnHh5osKyOpmObYmWNswZuxYAc0SYUrmfohkg2GaafKmPK0w@mail.gmail.com>	<20140217.141949.1387848185062797150.davem@davemloft.net>	<1392666165.65245.YahooMailNeo@web125505.mail.ne1.yahoo.com> <20140217.144858.1324303687260941756.davem@davemloft.net>
Reply-To: =?iso-8859-1?Q?Fran=E7ois-Xavier_Le_Bail?= <fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"christoph.paasch@uclouvain.be" <christoph.paasch@uclouvain.be>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm33.bullet.mail.ne1.yahoo.com ([98.138.229.26]:21998 "EHLO
	nm33.bullet.mail.ne1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753388AbaBQTzu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Feb 2014 14:55:50 -0500
In-Reply-To: <20140217.144858.1324303687260941756.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>





----- Original Message -----
> From: David Miller <davem@davemloft.net>
> To: fx.lebail@yahoo.com
> Cc: kuznet@ms2.inr.ac.ru; christoph.paasch@uclouvain.be; hannes@stres=
sinduktion.org; netdev@vger.kernel.org; eric.dumazet@gmail.com
> Sent: Monday, February 17, 2014 8:48 PM
> Subject: Re: [PATCH net-next v2] IPv6: enable bind() to assign an any=
cast address
>=20
> From: Fran=E7ois-Xavier Le Bail <fx.lebail@yahoo.com>
>=20
> Date: Mon, 17 Feb 2014 11:42:45 -0800 (PST)
>=20
>>  If I understand well the reviews, no change was ask for this patch.
>>  The sysctl was asked in case of patch for TCP.
>>  So, why the status is now "Changes Requested" ?=20
>=20
> This change is in generic bind() code, therefore it allows binding TC=
P
> sockets with anycast, therefore you need to make a change.

Understood, thanks.
