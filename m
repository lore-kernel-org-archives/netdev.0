From: "Satendra..." <satendra.pratap@gmail.com>
Subject: Re: IEEE 802.1ag / 802.1x / Y1731
Date: Fri, 1 Jul 2011 17:42:41 +0530
Message-ID: <BANLkTino1iUe3r3dmA5DraBZo6bYSSQ7Kg@mail.gmail.com>
References: <BANLkTingLv9XxLqU7nQSct8wqhyvkq=LqA@mail.gmail.com>
	<BANLkTimHM0ydiD5eEc2hzk+AQ1WBQQB97g@mail.gmail.com>
	<BANLkTim1VwXRiWdO6PWN6coDeOswQqSOXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Balaji G <balajig.foss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:52809 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209Ab1GAMMm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2011 08:12:42 -0400
Received: by gyh3 with SMTP id 3so1276322gyh.19
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2011 05:12:41 -0700 (PDT)
In-Reply-To: <BANLkTim1VwXRiWdO6PWN6coDeOswQqSOXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Balaji,
You mean CFM OAM 802.1ag can not be supported under linux yet.
I mean there are many routers which are running linux and if they want
to support CFM OAM on
their routers they will have to make changes in Linux networking stack?
Could you please tell about the support of Y.1731 / 802.1ah / 802.1x
in the linux networking
stack ?

Thanks,
Satendra

On 1 July 2011 15:51, Balaji G <balajig.foss@gmail.com> wrote:
>>Could anyone please tell me whether there is any support in Linux
>>networking stack=A0for 802.1ag ? If yes please mention the linux vers=
ion.
> Linux Kernel does not support 802.1ag
> Thanks,
> Cheers,
> =A0 - Balaji
>
>
>
> On Fri, Jul 1, 2011 at 1:46 PM, Satendra... <satendra.pratap@gmail.co=
m>
> wrote:
>>
>> Hello All,
>> Could anyone please tell me whether there is any support in Linux
>> networking stack
>> for 802.1ag ? If yes please mention the linux version.
>> What I need to do is to use CFM OAM (802.1ag) open source client on
>> our routers running linux
>> on them. Open source client to be used is dot1ag utils.
>>
>> Thanks,
>> Satendra
>>
>> On 24 June 2011 17:36, Satendra... <satendra.pratap@gmail.com> wrote=
:
>> > Hi,
>> > Could someone please tell me which version of linux has got suppor=
t
>> > for below (all three) protocols:
>> > - IEEE 802.1ag
>> > - 802.1x
>> > - Y1731
>> >
>> > Thanks,
>> > Satendra
>> >
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
>
