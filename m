From: Chen Gang <gang.chen@asianux.com>
Subject: [Consult] excuse me: sorry for the negative effects which I made.
Date: Thu, 29 Nov 2012 09:43:57 +0800
Message-ID: <50B6BDDD.1070402@asianux.com>
References: <50ADE447.8030300@asianux.com> <50AEEF08.4000707@asianux.com> <50B430B5.1080700@gmail.com> <50B43F12.1090709@asianux.com> <50B447F3.2090806@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Shan Wei <shanwei88@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:56104 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab2K2BnH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 20:43:07 -0500
In-Reply-To: <50B447F3.2090806@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Shan Wei, Eric, David

  maybe what I have done have made negative effect to you.
  I am sorry for that, firstly.
    excuse me, I am a newbie in *@vger.kernel.org, so not know many thi=
ngs.
    also excuse me, my English is not quite well (so at least, not quit=
e gentle)

  what I want to do is only to:
    provide contributes to outside, without negative effects, base on h=
uman resources limitations.
    but it seems that I am failed (at least, in net subsystem).

  next, I will be careful to continue under another sub systems, and le=
ave net sub system (at least for a while).

  sorry again for the negative effects which I made.

  Bye.

gchen.


=D3=DA 2012=C4=EA11=D4=C227=C8=D5 12:56, Shan Wei =D0=B4=B5=C0:
> Chen Gang said, at 2012/11/27 12:18:
>>>
>>>>
>>>>  for the format of information which seq_printf output:
>>>>    it is not belong to OS API level for outside (at least, for cur=
rent case, it is true).=20
>>>>    so we need not keep 'compatible' of it, so %16s is not necessar=
y.
>>>
>>> Can you explain If we don't change to %s, what will happen?
>>>
>>
>>   for outside, nothing will happen.
>>
>>   so it is not for correctness, it is only for "keep source code sim=
ple and clear".
>=20
> So, it's a clean-up type patch which is just for developer,
> but with the change of /proc interface which is for user.
> user is first, so let us end this thread unless you have necessary re=
asons to do it.=20
>=20
> Thanks =20
> Shan Wei
>=20
>=20


--=20
Chen Gang

Asianux Corporation
