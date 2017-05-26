From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH net-next 1/2] net: ndisc.c: fix coding style issue
Date: Sat, 27 May 2017 02:25:32 +0900
Message-ID: <CAPA1RqB1_ObcZc_rgE6HN+-PzsabWd2X=swGbkPxVLrzY60MKg@mail.gmail.com>
References: <1495805019-2919-1-git-send-email-cugyly@163.com>
 <CAPA1RqDqyZicNWM8arSvMfQjmy_A=LLEjtTwH8KTza4WwQ_dsg@mail.gmail.com> <1495806932.5755.4.camel@163.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: network dev <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Perches <joe@perches.com>, David Ahern <dsahern@gmail.com>,
        yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: cugyly@163.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:36275 "EHLO
        mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752354AbdEZRZy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 13:25:54 -0400
Received: by mail-io0-f173.google.com with SMTP id o12so13339614iod.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 10:25:54 -0700 (PDT)
In-Reply-To: <1495806932.5755.4.camel@163.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2017-05-26 22:55 GMT+09:00 yuan linyu <cugyly@163.com>:
> On =E4=BA=94, 2017-05-26 at 22:45 +0900, =E5=90=89=E8=97=A4=E8=8B=B1=E6=
=98=8E wrote:
>> Hi,
>>
>> 2017-05-26 22:23 GMT+09:00 yuan linyu <cugyly@163.com>:
>> >
>> > From: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>> >
>> > Signed-off-by: yuan linyu <Linyu.Yuan@alcatel-sbell.com.cn>
>> > ---
>> >  net/ipv6/ndisc.c | 109 ++++++++++++++++++++++++++++------------------=
---------
>> >  1 file changed, 55 insertions(+), 54 deletions(-)
>> Sorry, I don't think this kind of change for style is good
>> bacause this makes effort of  backport more difficult.
> hi, i can't understand.
> if any change of this code you decide to backport, it need effort,
> not only important fix.
>
> do I miss your point ?

Please let us minimize our effort when doing so.

If the style is not changed, we have more chance to apply the patch
itself on top of old tree.

Thank you.

>>
>> --yoshfuji
>>
>
>
