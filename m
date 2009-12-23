From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: release dst entry while cache-hot for GSO case too
Date: Wed, 23 Dec 2009 14:16:19 -0800 (PST)
Message-ID: <20091223.141619.59683447.davem@davemloft.net>
References: <20091210065958.10261.89370.sendpatchset@localhost.localdomain>
	<4B20AF6C.2060604@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44641
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757324AbZLWWQR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Dec 2009 17:16:17 -0500
In-Reply-To: <4B20AF6C.2060604@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 10 Dec 2009 09:21:00 +0100

> Le 10/12/2009 07:59, Krishna Kumar a =E9crit :
>> From: Krishna Kumar <krkumar2@in.ibm.com>
>>=20
>> Non-GSO code drops dst entry for performance reasons, but
>> the same is missing for GSO code. Drop dst while cache-hot
>> for GSO case too.
>>=20
>> Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
 ...
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
