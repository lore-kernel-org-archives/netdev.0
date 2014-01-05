From: Asi Lichtenstein <asili22@gmail.com>
Subject: Re: How to add IPv6 multiple routing tables support to 2.6.16.26 kernel
Date: Sun, 5 Jan 2014 16:09:21 +0200
Message-ID: <CAMBtn_2LttBQ6u5C_GEc1hh4=iSiAnzpN+2+MZO6j6GB2XBtNA@mail.gmail.com>
References: <CAMBtn_3jpNh=gvxkzVzSqgj3OEXYyqUdPb7Y63Jm-PVhx7U=DA@mail.gmail.com>
	<1388930162.16576.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Fran=E7ois=2DXavier_Le_Bail?= <fx.lebail@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:64627 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751141AbaAEOJY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 09:09:24 -0500
Received: by mail-oa0-f44.google.com with SMTP id h16so771038oag.3
        for <netdev@vger.kernel.org>; Sun, 05 Jan 2014 06:09:23 -0800 (PST)
In-Reply-To: <1388930162.16576.YahooMailBasic@web125504.mail.ne1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 5, 2014 at 3:56 PM, Fran=E7ois-Xavier Le Bail
<fx.lebail@yahoo.com> wrote:
> On Sun, 1/5/14, Asi Lichtenstein <asili22@gmail.com> wrote:
>
>> It does look promising, are there any other related
>> patches?
>
> I dont' know.
> I just follow the link "(patch)" at the url you sent.
> Please reply at end of message.
>
> BR
>
>> On Sun, Jan 5, 2014 at 3:25 PM, Fran=E7ois-Xavier Le Bail
>  <fx.lebail@yahoo.com>
>  wrote:
>> > Hello,
>> >
>> > Are you looking for this ?
>> > http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/pat=
ch/?id=3Dc71099acce933455123ee505cc75964610a209ad
>

I applied the patch you were referring to, but I think I am missing
some higher level code with netlink.
