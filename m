From: Asi Lichtenstein <asili22@gmail.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26 kernel
Date: Mon, 6 Jan 2014 10:56:17 +0200
Message-ID: <CAMBtn_3MaW+Hk=y7egXHo7sSEwdh-S=ZXs0Lne_ysf2pEOrrWA@mail.gmail.com>
References: <CAMBtn_3jpNh=gvxkzVzSqgj3OEXYyqUdPb7Y63Jm-PVhx7U=DA@mail.gmail.com>
	<1388930162.16576.YahooMailBasic@web125504.mail.ne1.yahoo.com>
	<CAMBtn_2LttBQ6u5C_GEc1hh4=iSiAnzpN+2+MZO6j6GB2XBtNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f54.google.com ([209.85.219.54]:49746 "EHLO
	mail-oa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752798AbaAFI4S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 03:56:18 -0500
Received: by mail-oa0-f54.google.com with SMTP id o6so1892326oag.13
        for <netdev@vger.kernel.org>; Mon, 06 Jan 2014 00:56:18 -0800 (PST)
In-Reply-To: <CAMBtn_2LttBQ6u5C_GEc1hh4=iSiAnzpN+2+MZO6j6GB2XBtNA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Does anyone know where I can find this patch:
http://thread.gmane.org/gmane.linux.network/41149

the link is broken, I've sent Thomas an email but did not get any respo=
nse.

10x

On Sun, Jan 5, 2014 at 4:09 PM, Asi Lichtenstein <asili22@gmail.com> wr=
ote:
> On Sun, Jan 5, 2014 at 3:56 PM, Fran=E7ois-Xavier Le Bail
> <fx.lebail@yahoo.com> wrote:
>> On Sun, 1/5/14, Asi Lichtenstein <asili22@gmail.com> wrote:
>>
>>> It does look promising, are there any other related
>>> patches?
>>
>> I dont' know.
>> I just follow the link "(patch)" at the url you sent.
>> Please reply at end of message.
>>
>> BR
>>
>>> On Sun, Jan 5, 2014 at 3:25 PM, Fran=E7ois-Xavier Le Bail
>>  <fx.lebail@yahoo.com>
>>  wrote:
>>> > Hello,
>>> >
>>> > Are you looking for this ?
>>> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/pa=
tch/?id=3Dc71099acce933455123ee505cc75964610a209ad
>>
>
> I applied the patch you were referring to, but I think I am missing
> some higher level code with netlink.
