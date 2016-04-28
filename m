From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 00/17] net: snmp: update SNMP methods
Date: Thu, 28 Apr 2016 14:20:12 +0200
Message-ID: <5721FFFC.9010808@6wind.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
 <5721E05B.1030603@6wind.com>
 <1461844854.5535.93.camel@edumazet-glaptop3.roam.corp.google.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f50.google.com ([74.125.82.50]:38886 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbcD1MU0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 08:20:26 -0400
Received: by mail-wm0-f50.google.com with SMTP id g17so38243268wme.1
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 05:20:25 -0700 (PDT)
In-Reply-To: <1461844854.5535.93.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 28/04/2016 14:00, Eric Dumazet a =C3=A9crit :
[snip]
> Hi Nicolas, thanks for testing.
>=20
> Oh right, I shouldn't have changed the BH disabling of 64bit stats on
> 32bit arches, of course.
>=20
> Can you double check this will fix the problem ? Thanks !
Thank you for the quick fix!

Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
