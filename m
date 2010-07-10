From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] act_nat: not all of the ICMP packets need an IP header
	payload
Date: Sat, 10 Jul 2010 22:08:36 +0800
Message-ID: <AANLkTimvRiFRLLStSogfI5H-eS01gMHZi1nFspgR4KbQ@mail.gmail.com>
References: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
	<1278742953.2538.24.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	=?ISO-8859-1?Q?Rodrigo_Partearroyo_Gonz=E1lez?=
	<rpartearroyo@albentia.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	=?ISO-8859-1?Q?Noelia_Mor=F3n?= <nmoron@albentia.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:33274 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755321Ab0GJOJB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 10:09:01 -0400
Received: by gwj18 with SMTP id 18so1429517gwj.19
        for <netdev@vger.kernel.org>; Sat, 10 Jul 2010 07:09:00 -0700 (PDT)
In-Reply-To: <1278742953.2538.24.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 2:22 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le samedi 10 juillet 2010 =E0 09:33 +0800, Changli Gao a =E9crit :
>
> Changli, this patch has no attribution.
>
> Rodrigo spent lot of time to find the problem and is willing to fix i=
t.
>
> Could you please give a chance to Rodrigo to complete its first kerne=
l
> patch ?
>

Oh. Sorry. The honor belongs to him. I think he can give his Sigh off,
if he thinks this patch is OK.

--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
