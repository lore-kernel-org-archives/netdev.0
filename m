From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: xfrm warning by mip6d
Date: Wed, 05 Oct 2011 15:55:50 +0200
Message-ID: <1317822950.2473.55.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4C76ADDE-B534-4C40-BBDA-DCADA5DD347D@wakoond.hu>
	 <1317810803.2473.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <34287764-C788-4718-BDD8-8B4DC98FE9F4@wakoond.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Andr=E1s_Tak=E1cs?= <linux-kernel@wakoond.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:61083 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755276Ab1JENzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Oct 2011 09:55:36 -0400
Received: by eya28 with SMTP id 28so1614830eya.19
        for <netdev@vger.kernel.org>; Wed, 05 Oct 2011 06:55:35 -0700 (PDT)
In-Reply-To: <34287764-C788-4718-BDD8-8B4DC98FE9F4@wakoond.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 05 octobre 2011 =C3=A0 15:32 +0200, Andr=C3=A1s Tak=C3=A1cs=
 a =C3=A9crit :
> Thanks for the help. I added this two skb_dst_force calls to my kerne=
l source, but unfortunately it didn't solved the problem.
>=20
> I know it's just a warning message, but I would be happy, if I could =
fix it.
>=20
> Does anybody have any other idea?

Is a more recent kernel issuing the same error ?
