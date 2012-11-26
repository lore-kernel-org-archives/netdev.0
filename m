From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] net: ipmr: limit MRT_TABLE identifiers
Date: Mon, 26 Nov 2012 11:13:47 +0800
Message-ID: <50B2DE6B.90708@asianux.com>
References: <50AC9CF6.2020501@asianux.com>  <1353872669.30446.863.camel@edumazet-glaptop>  <50B2C470.5090802@asianux.com>  <50B2C72F.9000100@asianux.com>  <1353896372.30446.866.camel@edumazet-glaptop>  <50B2D42A.6090804@asianux.com> <1353898520.30446.868.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:46412 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753753Ab2KZDMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Nov 2012 22:12:53 -0500
In-Reply-To: <1353898520.30446.868.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2012=E5=B9=B411=E6=9C=8826=E6=97=A5 10:55, Eric Dumazet =E5=86=
=99=E9=81=93:
> On Mon, 2012-11-26 at 10:30 +0800, Chen Gang wrote:
>=20
>>   maybe a hacker can do ?  (I just guess).
>>
>>   for my experience:
>>     It is necessary to think of more coding ways, when we have to gi=
ve comments inside a function.
>=20
> I have absolutely no idea of what you are trying to say.
>=20

excuse me, my English is not quite well.
I will try to say it as clear as I can.

what I want to say are:
  for os api, we need describe them as full as we can (including limita=
tions, although it seems minor).
  I do not suggest to give comments inside a fuction (especially coding=
 with hard code number).
  they are just my suggestion, not mean, it should be regression.

at least, I think this patch is valuable.


--=20
Chen Gang

Asianux Corporation
