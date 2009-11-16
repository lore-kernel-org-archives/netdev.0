From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v6 2/7 RFC] TCPCT part 1b: generate Responder
 Cookie
Date: Mon, 16 Nov 2009 15:06:04 -0500
Message-ID: <4B01B0AC.2050804@gmail.com>
References: <4AFCDA9E.8050003@gmail.com>  <4AFCDDC4.1090606@gmail.com>	 <1258093594.16857.43.camel@Joe-Laptop.home>  <4AFD728F.4030206@gmail.com> <1258135457.16857.107.camel@Joe-Laptop.home> <4B016424.1030403@gmail.com> <4B01710F.70800@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Joe Perches <joe@perches.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f202.google.com ([209.85.211.202]:34892 "EHLO
	mail-yw0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753297AbZKPUGB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 15:06:01 -0500
Received: by ywh40 with SMTP id 40so3442668ywh.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 12:06:07 -0800 (PST)
In-Reply-To: <4B01710F.70800@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> William Allen Simpson a =C3=A9crit :
>> Do I hear an Ack?
>>
> Fine by me William
>=20
> But you forgot to re-include full commit message and Signed-off-by:
>=20
> Yes it seems cumbersome, but David is handling ~50 patches per day,=20
> we shall give him as _perfect_ patches as possible.
>=20
Agreed, I understood that I'd need to send out the _entire_ patch serie=
s
without the RFC designation before our leader would consider it.

Right now, I'm just collecting as many comments, improvements, and Acks=
 as
possible before fetch, rebase, compiling, testing, and re-posting the
whole megillah again with "no fuzz" patches.

Hopefully, splitting this into more sub-parts (as you requested) enable=
s
reviewing, but of course it's an exponential increase in preparation an=
d
test time.  So, I'm trying to get some comments on every sub-part.
