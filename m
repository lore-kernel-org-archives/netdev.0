From: feng tian <feng.of.tian@gmail.com>
Subject: Re: Abour linux driver supports BCM4325
Date: Sat, 22 Aug 2009 13:11:29 +0800
Message-ID: <f42a38140908212211m5faeae7ajba133a3d2535d2c0@mail.gmail.com>
References: <f42a38140908202319y5c352aa3s37fec67e5cb8d7a3@mail.gmail.com>
	 <f42a38140908202322ua3d4486meae6653044465583@mail.gmail.com>
	 <1250860381.2876.19.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:36832 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbZHVFL2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2009 01:11:28 -0400
Received: by bwz19 with SMTP id 19so742585bwz.37
        for <netdev@vger.kernel.org>; Fri, 21 Aug 2009 22:11:29 -0700 (PDT)
In-Reply-To: <1250860381.2876.19.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks very much, I'll post this to linux-wireless mailing list.

2009/8/21 Dan Williams <dcbw@redhat.com>:
> On Fri, 2009-08-21 at 14:22 +0800, feng tian wrote:
>> Dear All,
>>
>> We are working on a project which supports the BCM4325 linux wireles=
s
>> driver. The interface between the BCM chip and SOC(pxa310) is SDIO.
>> I did some searches online and found that there is no available driv=
er
>> for this chip. Do I have to implement this myself? Is there anyone c=
an
>> provide us some related materials? =A0Thanks very much.
>
> You'll probably want to ask on the linux-wireless list where the
> wireless people hang out. =A0Partial answer: there is already a drive=
r
> (b43) for many of broadcom 802.11 devices, including some of the
> "LP-PHY" devices. =A0This driver may or may not be suitable for the 4=
325
> depending on the 4325's firmware interface. =A0The b43 driver is not =
yet
> capable of using SDIO to communicate with the wifi chip, but that
> appears to be what you are working on. =A0So I'd suggest posting to t=
he
> linux-wireless mailing list and seeing what the b43 driver people say=
=2E
>
> http://linuxwireless.org/en/developers/MailingLists
>
> Dan
>
>
>
