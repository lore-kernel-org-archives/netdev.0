From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: implement SIOCINQ ioctl() (take 3 bis)
Date: Fri, 15 Oct 2010 09:59:40 -0700 (PDT)
Message-ID: <20101015.095940.39172218.davem@davemloft.net>
References: <20100930.173557.108787840.davem@davemloft.net>
	<1285926965-5130-1-git-send-email-flameeyes@gmail.com>
	<1287152557.465.24.camel@yamato.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: flameeyes@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46378
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932166Ab0JOQ7S convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 12:59:18 -0400
In-Reply-To: <1287152557.465.24.camel@yamato.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Diego Elio Petten=F2 <flameeyes@gmail.com>
Date: Fri, 15 Oct 2010 16:22:37 +0200

> Il giorno ven, 01/10/2010 alle 11.56 +0200, Diego Elio Petten=F2 ha
> scritto:
>>=20
>>=20
>> This simple patch copies the current approach for SIOCINQ ioctl() fr=
om
>> DCCP
>> into SCTP so that the userland code working with SCTP can use a
>> similar
>> interface across different protocols to know how much space to
>> allocate for
>> a buffer.=20
>=20
> Any news on getting this one in? Pretty please? :)

I'm pretty sure it's in the net-next-2.6, is it not?
