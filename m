From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] Net-next: ipv4: type issue, remove erroneous semicolon
Date: Tue, 23 Apr 2013 09:46:13 +0800
Message-ID: <5175E7E5.8020600@asianux.com>
References: <51750E31.2010906@asianux.com> <20130422.154423.1695741341535269869.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: pshelar@nicira.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:19480 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753479Ab3DWBrA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 21:47:00 -0400
In-Reply-To: <20130422.154423.1695741341535269869.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013=E5=B9=B404=E6=9C=8823=E6=97=A5 03:44, David Miller wrote:
> From: Chen Gang <gang.chen@asianux.com>
> Date: Mon, 22 Apr 2013 18:17:21 +0800
>=20
>>   need remove erroneous semicolon.
>>
>>   the related commit number: c54419321455631079c7d6e60bc732dd0c5914c=
5
>>
>>   Find it by EXTRA_CFLAGS=3D-W
>>
>>
>> Signed-off-by: Chen Gang <gang.chen@asianux.com>
>=20
> First, what is a "type issue", you aren't changing any variable
> or declaration types in this change.
>=20

  sorry for my poor English, maybe 'type issue' need change to 'typo
issue' ?


> Second, your formatting of your commit messages is terrible.
>=20
> Do not indent the description with two spaces, just keep them at the
> leftmost column.  Where did you learn to indent things like that, who
> else does that?  If you've never seen it before, don't invent things.
>=20

  ok, excuse me, what I have done is only to try to make my expression
is as clearer as I can. my English is not quite well, I am afraid to le=
t
other members can not understand or misunderstand what I write.

  but since you dislike it, I will not send messages like that to you.

> It is very irritating when we see people write commit messages with
> their own style rather than mimicking what other successful
> contributors are doing.
>=20

  sorry, I am not quite understand what your meaning. I guess your
meaning is: "you are very angry to see a member write message with his
own style. if a member is a successful contributor, he never writes
message with his own style, he only follow the public standard style".

  is what I guess correct ?

  thanks.

> Thanks.
>=20
>=20


--=20
Chen Gang

Asianux Corporation
