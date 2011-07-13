From: "Satendra..." <satendra.pratap@gmail.com>
Subject: Re: IEEE 802.1ag / 802.1x / Y1731
Date: Wed, 13 Jul 2011 15:09:17 +0530
Message-ID: <CAChS5kM9ZNcGAsJsoUVwWj_SJ_-KwgVOTafAwiQR+8C3kWJ_Xg@mail.gmail.com>
References: <BANLkTingLv9XxLqU7nQSct8wqhyvkq=LqA@mail.gmail.com>
	<BANLkTimHM0ydiD5eEc2hzk+AQ1WBQQB97g@mail.gmail.com>
	<BANLkTim1VwXRiWdO6PWN6coDeOswQqSOXA@mail.gmail.com>
	<BANLkTino1iUe3r3dmA5DraBZo6bYSSQ7Kg@mail.gmail.com>
	<BANLkTi=qe9f_zJRqC9nuzMGViy0YLAzJJg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: equinox@diac24.net, netdev@vger.kernel.org
To: Balaji G <balajig.foss@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:36903 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965136Ab1GMJjS convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 05:39:18 -0400
Received: by yxi11 with SMTP id 11so2314605yxi.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 02:39:17 -0700 (PDT)
In-Reply-To: <BANLkTi=qe9f_zJRqC9nuzMGViy0YLAzJJg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Balaji,
Thanks for sharing this information.
We have decided to use dot1ag utils for 802.1ag. Its a user space
implementation of 802.1ag.

I have a question: is there any development going on for Y.1731 for
linux or freebsd
either as user space application like dot1ag OR network stack
enhancements OR anything else)?

Thanks,
Satendra

On 2 July 2011 13:22, Balaji G <balajig.foss@gmail.com> wrote:
> Hi
> Currently ECFM is supported @ the user space level or rather lot of
> companies buy L2 stacks and integrate it with the OS so these stacks =
have
> ECFM support. When we talk about ECFM we need to really find out whet=
her we
> are going to talk about suppporting ECFM over Provider Bridging Ports=
 or are
> we gonna support ECFM over PBB which is 802.1AH because the place whe=
re we
> configure ECFM entities play an important role and this could be defi=
ned
> only if we get to know on what we support ECFM. But as on date Linux =
kernel
> does not have support for ECFM or for Y.1731
> Cheers,
> =A0 - Balaji
>
> On Fri, Jul 1, 2011 at 5:42 PM, Satendra... <satendra.pratap@gmail.co=
m>
> wrote:
>>
>> Hi Balaji,
>> You mean CFM OAM 802.1ag can not be supported under linux yet.
>> I mean there are many routers which are running linux and if they wa=
nt
>> to support CFM OAM on
>> their routers they will have to make changes in Linux networking sta=
ck?
>> Could you please tell about the support of Y.1731 / 802.1ah / 802.1x
>> in the linux networking
>> stack ?
>>
>> Thanks,
>> Satendra
>>
>> On 1 July 2011 15:51, Balaji G <balajig.foss@gmail.com> wrote:
>> >>Could anyone please tell me whether there is any support in Linux
>> >>networking stack=A0for 802.1ag ? If yes please mention the linux v=
ersion.
>> > Linux Kernel does not support 802.1ag
>> > Thanks,
>> > Cheers,
>> > =A0 - Balaji
>> >
>> >
>> >
>> > On Fri, Jul 1, 2011 at 1:46 PM, Satendra... <satendra.pratap@gmail=
=2Ecom>
>> > wrote:
>> >>
>> >> Hello All,
>> >> Could anyone please tell me whether there is any support in Linux
>> >> networking stack
>> >> for 802.1ag ? If yes please mention the linux version.
>> >> What I need to do is to use CFM OAM (802.1ag) open source client =
on
>> >> our routers running linux
>> >> on them. Open source client to be used is dot1ag utils.
>> >>
>> >> Thanks,
>> >> Satendra
>> >>
>> >> On 24 June 2011 17:36, Satendra... <satendra.pratap@gmail.com> wr=
ote:
>> >> > Hi,
>> >> > Could someone please tell me which version of linux has got sup=
port
>> >> > for below (all three) protocols:
>> >> > - IEEE 802.1ag
>> >> > - 802.1x
>> >> > - Y1731
>> >> >
>> >> > Thanks,
>> >> > Satendra
>> >> >
>> >> --
>> >> To unsubscribe from this list: send the line "unsubscribe netdev"=
 in
>> >> the body of a message to majordomo@vger.kernel.org
>> >> More majordomo info at =A0http://vger.kernel.org/majordomo-info.h=
tml
>> >
>> >
>
>
