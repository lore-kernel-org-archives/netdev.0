From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET: fix wrong English expression in comments
Date: Tue, 13 Jan 2009 08:57:59 +0100
Message-ID: <496C4987.8040803@cosmosbay.com>
References: <496a3c51.09876e0a.03fe.7e80@mx.google.com>	<496A9753.80802@cn.fujitsu.com>	<6b1ba94c0901122336r511fa316o5f520a8d2d9d6e0@mail.gmail.com> <20090112.234441.131571840.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: joe.tian.kernel@gmail.com, lizf@cn.fujitsu.com,
	qhfeng.kernel@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41019 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbZAMH6M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 02:58:12 -0500
In-Reply-To: <20090112.234441.131571840.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: joe tian <joe.tian.kernel@gmail.com>
> Date: Tue, 13 Jan 2009 15:36:51 +0800
>=20
>> 2009/1/12 Li Zefan <lizf@cn.fujitsu.com>:
>>>> @@ -103,7 +103,7 @@ struct inet_bind_bucket;
>>>>  struct inet_timewait_sock {
>>>>       /*
>>>>        * Now struct sock also uses sock_common, so please just
>>>> -      * don't add nothing before this first member (__tw_common) =
--acme
>>>> +      * don't add anything before this first member (__tw_common)=
 --acme
>>> They are the same meaning...
>>>
>> I don't think they are the same meaning.
>> I think "don't add anything" means "do add nothing" but not means "d=
on't add
>> nothing"
>=20
> No offense to anyone, but the only people arguing for "correctness"
> seem to be non-native speakers of English.  Is this correct? :-)
>=20
> As Ben tries to explain, "don't add nothing" is a colloquialism of
> English that in fact can mean "do not add"
>=20
> It sounds amusing when read, and I'm not killing the character and
> personality of this comment just for some language lawyering.
>=20
> No way.

Oh my God... time for me to check what is a colloquialism :)


According to wikipedia :

A colloquialism is an expression not used in formal speech,=20
writing or paralinguistics. Colloquialisms are also sometimes=20
referred to collectively as "colloquial language". [1] Colloquialisms
or colloquial language is considered to be characteristic of or only
appropriate for casual, ordinary, familiar, or informal conversation
rather than formal speech or writing.[2] Dictionaries often display
colloquial words and phrases with the abbreviation colloq. as an identi=
fier.


Ouch... back to coding :)

