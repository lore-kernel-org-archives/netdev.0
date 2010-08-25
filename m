From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 1/1]: bna: Fix build break for allyesconfig
Date: Wed, 25 Aug 2010 23:52:53 +0200
Message-ID: <1282773173.2681.246.camel@edumazet-laptop>
References: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, amathur@brocade.com, ddutt@brocade.com,
	huangj@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51263 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400Ab0HYWJJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Aug 2010 18:09:09 -0400
Received: by wyb35 with SMTP id 35so1240757wyb.19
        for <netdev@vger.kernel.org>; Wed, 25 Aug 2010 15:09:07 -0700 (PDT)
In-Reply-To: <201008252132.o7PLWA0j029512@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 25 ao=C3=BBt 2010 =C3=A0 14:32 -0700, Rasesh Mody a =C3=A9c=
rit :
> From: Rasesh Mody <rmody@brocade.com>
>=20
> This patch contains a fix for the build break caused by multiple
> definitions of symbols between Brocade's FC/FCOE driver(BFA)=20
> and 10G Networking Driver(BNA).
>=20
> The fix is to make BNA a module only driver.
>=20
> Signed-off-by: Debashis Dutt <ddutt@brocade.com>
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  Kconfig |    2 +-
>  1 files changed, 1 insertion(+), 1 deletion(-)
>=20

small note about diffstat : please use -p1 -w70 options for next
submissions.=20

I wont comment on the patch itself.


